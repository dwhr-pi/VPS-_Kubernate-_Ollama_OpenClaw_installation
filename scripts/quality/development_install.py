"""Explicit private GitHub builds/packages for the 62-source catalog. No daemon startup."""
import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import signal
import stat
import subprocess
import sys
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[2]
OWNER = "openclaw-development-install-v1"
ID = re.compile(r"[a-z0-9_]+")
REF = re.compile(r"[A-Za-z0-9][A-Za-z0-9_./-]{0,150}")


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def catalog():
    rows = read_json(ROOT / "config/development_toolchains.json")["tools"]
    recipes = read_json(ROOT / "config/development_installers.json")["recipes"]
    if len(rows) != 62 or len({row["id"] for row in rows}) != 62:
        raise ValueError("62 eindeutige Katalogeintraege erforderlich.")
    for row in rows:
        if not ID.fullmatch(row["id"]) or row["id"] not in recipes:
            raise ValueError("Fehlendes Installationsrezept.")
        recipe = recipes[row["id"]]
        if recipe["mode"] == "existing":
            for path in recipe["scripts"].values():
                if not isinstance(path, str) or not re.fullmatch(r"scripts/tools/[a-z0-9_]+\.sh", path):
                    raise ValueError("Ungueltiger bestehender Skriptpfad.")
        else:
            if not recipe.get("steps") and recipe["mode"] != "workflow-package":
                raise ValueError("Leeres Buildrezept.")
            if not re.fullmatch(r"https://github.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", row["source"]):
                raise ValueError("Nur katalogisierte GitHub-Quellen erlaubt.")
            if not recipe.get("artifacts"):
                raise ValueError("Erfolgsartefakt fehlt.")
            if not re.fullmatch(r"https://github.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", recipe.get("source", row["source"])):
                raise ValueError("Ungueltige Buildquelle.")
    return {row["id"]: {**row, "recipe": recipes[row["id"]]} for row in rows}


def checked(path):
    path = Path(path).absolute()
    for parent in (path, *path.parents):
        try:
            info = parent.lstat()
        except FileNotFoundError:
            continue
        if stat.S_ISLNK(info.st_mode) or getattr(info, "st_file_attributes", 0) & 0x400:
            raise ValueError("Symlink/Junction im verwalteten Zielpfad; keine Aenderung.")
    return path


def safe_relative(base, value):
    relative = Path(value)
    if relative.is_absolute() or ".." in relative.parts or "\\" in value:
        raise ValueError("Ungueltiger relativer Artefaktpfad.")
    target = checked(base / relative)
    if not target.is_relative_to(Path(base).absolute()):
        raise ValueError("Pfad ausserhalb des privaten Bereichs.")
    return target


def workspace():
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absolutes User-Datenverzeichnis erforderlich, keine Dateisystemwurzel.")
    if raw.resolve().is_relative_to(ROOT.resolve()):
        raise ValueError("Installationen ausserhalb des Setup-Checkouts ablegen.")
    return checked(raw / "development-tools")


def digest(path):
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024**2), b""):
            value.update(block)
    return value.hexdigest()


def atomic_json(path, value):
    pending = path.with_name(path.name + "." + uuid.uuid4().hex + ".tmp")
    try:
        with pending.open("x", encoding="utf-8") as stream:
            json.dump(value, stream, ensure_ascii=True, indent=2)
        os.replace(pending, path)
    finally:
        pending.unlink(missing_ok=True)


@contextmanager
def lock(base):
    base.mkdir(parents=True, exist_ok=True, mode=0o700)
    path = checked(base / ".operation.lock")
    try:
        fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError:
        raise ValueError("Ein Entwicklungs-Tool-Job laeuft bereits. Verwaisten Lock nur nach Prozesspruefung entfernen.") from None
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(str(os.getpid()))
        yield
    finally:
        path.unlink(missing_ok=True)


def verify(base, tool):
    marker = checked(base / tool / "installed.json")
    receipt = read_json(marker)
    if (receipt.get("owner") != OWNER or receipt.get("tool") != tool or
            not re.fullmatch(r"generation-[0-9a-f]{32}", receipt.get("generation", "")) or
            not re.fullmatch(r"[0-9a-f]{40}", receipt.get("commit", ""))):
        raise ValueError("Ungueltiger Besitz-/Buildnachweis.")
    generation = safe_relative(base / tool, receipt["generation"])
    if read_json(generation / "owner.json") != {"owner": OWNER, "tool": tool}:
        raise ValueError("Generation ohne Besitznachweis.")
    artifacts = receipt.get("artifacts")
    if not isinstance(artifacts, dict) or not artifacts:
        raise ValueError("Keine nachgewiesenen Artefakte.")
    for relative, expected in artifacts.items():
        path = safe_relative(generation, relative)
        if not path.is_file() or digest(path) != expected:
            raise ValueError("Artefakt fehlt/veraendert. Kein installiert-Status und keine automatische Loeschung.")
    return receipt


def remove_generation(base, tool, generation):
    if not re.fullmatch(r"generation-[0-9a-f]{32}", generation):
        raise ValueError("Ungueltiges Loeschziel.")
    target = safe_relative(base / tool, generation)
    if read_json(target / "owner.json") != {"owner": OWNER, "tool": tool}:
        raise ValueError("Fremde Dateien bleiben erhalten.")
    # Refuse symlink escapes even inside a failed job; never follow them for deletion.
    def writable_retry(function, path, error):
        os.chmod(path, 0o700)
        function(path)
    shutil.rmtree(target, onerror=writable_retry)


def budget(base, row):
    recipe = row["recipe"]
    disk = max(row["disk_mb"], recipe.get("disk_mb", 1024))
    ram = max(row["ram_mb"], recipe.get("ram_mb", 512))
    target = checked(base)
    while not target.exists():
        target = target.parent
    free = shutil.disk_usage(target).free // 1024**2
    print("Freie Ziel-Disk MiB:", free, "Reserve:", disk, flush=True)
    if free < disk:
        raise ValueError("Speicherplatzmangel vor Download/Build; keine neue Installation begonnen.")
    if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").is_dir():
        host = shutil.disk_usage("/mnt/c").free // 1024**2
        print("Freier Windows-Host-Speicher C: MiB:", host, flush=True)
        if host < disk:
            raise ValueError("Speicherplatzmangel: konservative Windows-C:-Reserve unterschritten.")
    if Path("/proc/meminfo").is_file():
        info = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
        if int(info["MemAvailable"].split()[0]) // 1024 < ram:
            raise ValueError("RAM unter Buildreserve: " + str(ram) + " MiB.")
    if recipe.get("heavy") and os.environ.get("INSTALL_HEAVY_TOOLS") != "1":
        raise ValueError("Schwerer Build: INSTALL_HEAVY_TOOLS=1 bewusst setzen.")


def build_env(generation):
    env = {key: os.environ[key] for key in ("PATH", "SystemRoot", "WINDIR", "LANG", "LC_ALL") if key in os.environ}
    for name in ("home", "cache", "tmp", "payload"):
        (generation / name).mkdir(mode=0o700)
    (generation / "payload/bin").mkdir(mode=0o700)
    env.update(HOME=str(generation / "home"), USERPROFILE=str(generation / "home"),
               TMPDIR=str(generation / "tmp"), TMP=str(generation / "tmp"), TEMP=str(generation / "tmp"),
               XDG_CACHE_HOME=str(generation / "cache"), CI="1", GIT_TERMINAL_PROMPT="0",
               GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull,
               GIT_ALLOW_PROTOCOL="https", GIT_LFS_SKIP_SMUDGE="1",
               GOTOOLCHAIN="local", GOENV="off", GOWORK="off", GOFLAGS="", GOMAXPROCS="2",
               GOPATH=str(generation / "cache/go"), GOCACHE=str(generation / "cache/go-build"),
               CARGO_TARGET_DIR=str(generation / "target"), CARGO_BUILD_JOBS="2",
               CARGO_HOME=str(generation / "cache/cargo"),
               npm_config_cache=str(generation / "cache/npm"), npm_config_audit="false",
               npm_config_fund="false", npm_config_engine_strict="true", npm_config_jobs="2",
               PUPPETEER_SKIP_DOWNLOAD="true", PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="1",
               COREPACK_HOME=str(generation / "cache/corepack"),
               CMAKE_BUILD_PARALLEL_LEVEL="2", MAKEFLAGS="-j2",
               npm_config_workspace_concurrency="2", DOTNET_CLI_TELEMETRY_OPTOUT="1",
               DOTNET_CLI_HOME=str(generation / "home/dotnet"),
               DEVTOOLS_PREFIX=str(generation / "payload"))
    # Reuse explicitly installed compiler toolchains, without changing their profiles/settings.
    for key in ("RUSTUP_HOME", "GOROOT_BOOTSTRAP", "DOTNET_ROOT"):
        if key in os.environ:
            env[key] = os.environ[key]
    env.setdefault("RUSTUP_HOME", str(Path.home() / ".rustup"))
    env["RUSTUP_AUTO_INSTALL"] = "0"
    return env


def run(argv, cwd, env, log, capture=False, timeout=7200):
    print("Phase:", argv[0], "|", cwd.name, flush=True)
    log.write("\nCOMMAND " + json.dumps(argv) + "\n")
    log.flush()
    # Each phase gets a process group so timeouts also stop compiler grandchildren.
    process = subprocess.Popen(argv, cwd=cwd, env=env, stdin=subprocess.DEVNULL,
                               stdout=subprocess.PIPE if capture else log, stderr=log,
                               text=True, start_new_session=os.name != "nt")
    try:
        output, _ = process.communicate(timeout=timeout)
    except (subprocess.TimeoutExpired, KeyboardInterrupt):
        if os.name != "nt":
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        else:
            process.kill()
        process.communicate()
        raise ValueError("Build abgebrochen/Zeitlimit; Prozess beendet, Details im aktuellen Log.") from None
    if process.returncode:
        raise ValueError("Buildphase fehlgeschlagen (Exit " + str(process.returncode) + "); siehe aktuelles Log.")
    return (output or "").strip()


def artifacts(generation, patterns):
    found = {}
    for alternatives in patterns:
        matches = []
        for pattern in alternatives:
            if Path(pattern).is_absolute() or ".." in Path(pattern).parts:
                raise ValueError("Ungueltiges Artefaktmuster.")
            matches.extend(generation.glob(pattern))
        files = [path for path in matches if path.is_file() and path.stat().st_size]
        if not files:
            raise ValueError("Erwartetes Buildartefakt fehlt: " + " oder ".join(alternatives))
        for path in files:
            relative = path.relative_to(generation).as_posix()
            safe_relative(generation, relative)
            found[relative] = digest(path)
    return found


def build_host_supported():
    return os.name != "nt"


def private_tool_path(base):
    folders = []
    for tool, binary in (("node_js", "node"), ("go", "go"), ("cmake", "cmake"),
                         ("cargo", "cargo"), ("powershell", "pwsh")):
        try:
            receipt = verify(base, tool)
        except (OSError, ValueError, KeyError, TypeError):
            continue
        for relative in receipt["artifacts"]:
            if Path(relative).name == binary:
                folders.append(str(safe_relative(base / tool / receipt["generation"], relative).parent))
    return os.pathsep.join(folders + [os.environ.get("PATH", "")])


def install(base, row, ref, accept, log):
    if not accept:
        raise ValueError("GitHub-Build fuehrt fremden Buildcode aus und laedt Dependencies. --accept-build-risk erforderlich.")
    if not build_host_supported():
        raise ValueError("Neue private Buildrezepte sind fuer Linux/macOS; kein automatischer WSL-Aufruf unter Windows.")
    tool, recipe = row["id"], row["recipe"]
    marker = checked(base / tool / "installed.json")
    previous = verify(base, tool) if marker.exists() else None
    if previous and ref is None:
        print("Bereits installiert/geprueft; --ref fuer bewusst gewaehlten neuen Stand verwenden.")
        return
    budget(base, row)
    if recipe.get("platform") == "linux-amd64" and (sys.platform != "linux" or platform.machine().lower() not in ("x86_64", "amd64")):
        raise ValueError("Dieses Rezept ist ausdruecklich auf Linux amd64 begrenzt; kein falsches ARM-Artefakt bauen.")
    tool_path = private_tool_path(base)
    for requirement in recipe["requirements"]:
        if not any(shutil.which(name, path=tool_path) for name in requirement):
            raise ValueError("Buildwerkzeug fehlt: " + " oder ".join(requirement) + "; keine Systeminstallation.")
    selected_ref = ref or recipe.get("ref", "HEAD")
    if not REF.fullmatch(selected_ref) or ".." in selected_ref or selected_ref.endswith("/"):
        raise ValueError("Ungueltige Git-Referenz.")
    parent = checked(base / tool)
    parent.mkdir(exist_ok=True, mode=0o700)
    generation = parent / ("generation-" + uuid.uuid4().hex)
    generation.mkdir(mode=0o700)
    published = False
    owner_written = False
    try:
        atomic_json(generation / "owner.json", {"owner": OWNER, "tool": tool})
        owner_written = True
        env = build_env(generation)
        env["PATH"] = tool_path
        source = generation / "source"
        run(["git", "init", str(source)], generation, env, log)
        build_source = recipe.get("source", row["source"])
        run(["git", "-c", "credential.helper=", "-c", "http.followRedirects=false", "fetch", "--depth=1",
             build_source + ".git", selected_ref], source, env, log)
        commit = run(["git", "rev-parse", "FETCH_HEAD^{commit}"], source, env, log, capture=True, timeout=30)
        if not re.fullmatch(r"[0-9a-f]{40}", commit):
            raise ValueError("Kein eindeutiger Git-Commit ermittelt.")
        run(["git", "-c", "advice.detachedHead=false", "checkout", "--detach", commit], source, env, log)
        if recipe.get("bootstrap_go") and "GOROOT_BOOTSTRAP" not in env:
            env["GOROOT_BOOTSTRAP"] = run(["go", "env", "GOROOT"], source, env, log, capture=True, timeout=30)
        values = {"source": str(source), "prefix": str(generation / "payload"),
                  "job": str(generation), "python": sys.executable}
        print("GitHub-Commit:", commit, "| Art:", recipe["mode"], flush=True)
        for step in recipe["steps"]:
            budget(base, row)
            argv = [arg.format_map(values) for arg in step["argv"]]
            cwd = safe_relative(generation, step.get("cwd", "source"))
            cwd.mkdir(parents=True, exist_ok=True)
            run(argv, cwd, env, log)
        if recipe["mode"] == "workflow-package":
            metadata = next((name for name in ("action.yml", "action.yaml") if (source / name).is_file()), None)
            if not metadata:
                raise ValueError("Keine GitHub-Action-Metadaten; kein installiert-Status.")
            atomic_json(generation / "payload/workflow-reference.json", {
                "uses": row["repo"] + "@" + commit, "enabled": False,
                "checkout": str(source), "note": "Keine .github/workflows-Datei aktiviert."})
        found = artifacts(generation, recipe["artifacts"])
        receipt = {"owner": OWNER, "tool": tool, "generation": generation.name,
                   "commit": commit, "ref": selected_ref, "source": build_source,
                   "mode": recipe["mode"], "artifacts": found,
                   "runtime_tested": False, "installed_at": datetime.now(timezone.utc).isoformat()}
        atomic_json(marker, receipt)
        published = True
        print("Installationsartefakte erzeugt und SHA256-geprueft:", generation, flush=True)
        print("Kein Dienst, Daemon, Cluster, Editor, Datenbank oder Workflow gestartet/aktiviert.")
        if previous:
            print("Vorherige Generation als Sicherung erhalten:", previous["generation"])
    finally:
        if not published:
            if owner_written:
                remove_generation(base, tool, generation.name)
            else:
                generation.rmdir()
            print("Rollback: nur neue Jobdateien entfernt; bestehende Installation und aktuelles Log bleiben erhalten.", flush=True)


def existing_script(row, action):
    recipe = row["recipe"]
    value = recipe["scripts"].get(action)
    if not value:
        raise ValueError("Dieser bestehende Adapter unterstuetzt diese Aktion nicht.")
    path = safe_relative(ROOT, value)
    if not path.is_file() or "stub" in path.name:
        raise ValueError("Bestehender Installer fehlt/ist ein Platzhalter.")
    return path


def main(argv=None):
    rows = catalog()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("list", "plan", "install", "update", "uninstall", "status", "doctor"))
    parser.add_argument("--tool", choices=sorted(rows))
    parser.add_argument("--ref", help="Bewusster neuer Tag/Commit; ohne Angabe bleibt vorhandener Stand erhalten")
    parser.add_argument("--accept-build-risk", action="store_true")
    args = parser.parse_args(argv)
    if args.action == "list":
        for row in sorted(rows.values(), key=lambda row: row["name"].upper()):
            print(row["id"] + "|" + row["name"] + "|" + row["recipe"]["mode"])
        return 0
    if args.tool is None:
        parser.error("--tool erforderlich; kein automatischer 62er-Massenbuild.")
    row = rows[args.tool]
    recipe = row["recipe"]
    if args.action == "plan":
        print(json.dumps({"tool": row["id"], "source": row["source"], "recipe": recipe,
                          "network_accessed": False, "installed": False}, ensure_ascii=True, indent=2))
        return 0
    base = workspace()
    if args.action in ("status", "doctor") and recipe["mode"] != "existing":
        try:
            receipt = verify(base, row["id"])
            print(json.dumps({"installed": True, "mode": receipt["mode"], "commit": receipt["commit"], "runtime_tested": False}))
            return 0
        except (OSError, ValueError, KeyError, TypeError):
            print(json.dumps({"installed": False, "runtime_tested": False}))
            return int(args.action == "doctor")
    if recipe["mode"] == "existing":
        action = "status" if args.action == "doctor" else args.action
        path = existing_script(row, action)
        if args.ref:
            raise ValueError("Bestehender Adapter verwaltet seinen eigenen Pin; --ref dort nicht durchreichen.")
        if args.action in ("install", "update") and not args.accept_build_risk:
            raise ValueError("--accept-build-risk erforderlich; bestehender Adapter wird bewusst gestartet.")
        bash = shutil.which("bash")
        if os.name == "nt":
            raise ValueError("Kein WSL-Aufruf. Bestehenden Bash-Installer auf dem vorgesehenen Linux-Host ausfuehren.")
        if not bash:
            raise ValueError("Bash fehlt.")
        with lock(base):
            return subprocess.run([bash, str(path)], cwd=ROOT, check=False).returncode
    with lock(base):
        logs = checked(base / "logs")
        logs.mkdir(exist_ok=True, mode=0o700)
        fd, name = tempfile.mkstemp(prefix=args.tool + "_" + args.action + "_", suffix=".log", dir=logs)
        print("Aktuelles Log:", name, flush=True)
        with os.fdopen(fd, "w", encoding="utf-8", buffering=1) as log:
            log.write("Start " + datetime.now(timezone.utc).isoformat() + " " + args.tool + " " + args.action + "\n")
            try:
                if args.action == "uninstall":
                    receipt = verify(base, args.tool)
                    remove_generation(base, args.tool, receipt["generation"])
                    (base / args.tool / "installed.json").unlink()
                    print("Eigene aktive Generation entfernt; Compiler/Basiswerkzeuge, Sicherungen und Logs bleiben erhalten.")
                else:
                    install(base, row, args.ref, args.accept_build_risk, log)
                log.write("Ergebnis: success\n")
            except BaseException as exc:
                log.write("Ergebnis: failed; " + str(exc) + "\n")
                raise
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as exc:
        print("Development-Installation:", exc, file=sys.stderr)
        sys.exit(1)
