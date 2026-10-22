"""Pinned optional GitHub tools; desktop builds and source preparation are distinct."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys

from find_skills import checked, git, operation
from webinar_releases import reserve

MANIFEST = Path(__file__).with_name("gap_tools.json")
SPECS = json.loads(MANIFEST.read_text(encoding="utf-8"))


def paths(key):
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluter externer User-Workspace erforderlich.")
    base = checked(raw / "tools" / key)
    return base, checked(base / "runtime"), checked(base / "ready.json")


def inventory(root):
    result = {}
    # rglob does not follow directory symlinks; record venv links without reading targets.
    for path in sorted(root.rglob("*")):
        name = path.relative_to(root).as_posix()
        if path.is_symlink():
            result[name] = "link:" + os.readlink(path)
        elif path.is_file():
            digest = hashlib.sha256()
            with path.open("rb") as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                    digest.update(chunk)
            result[name] = digest.hexdigest()
        elif not path.is_dir():
            raise ValueError("Spezialdatei im privaten Tool-Verzeichnis.")
    return result


def build_env(runtime):
    allow = {"PATH", "SystemRoot", "SYSTEMROOT", "COMSPEC", "PATHEXT", "LANG", "LC_ALL",
             "RUSTUP_HOME", "CARGO_HOME", "INCLUDE", "LIB", "LIBPATH", "VCToolsInstallDir",
             "WindowsSdkDir", "WindowsSDKVersion", "LD_LIBRARY_PATH"}
    env = {k: v for k, v in os.environ.items() if k in allow}
    home = runtime / ".build-home"
    temp = runtime / ".build-temp"
    home.mkdir(exist_ok=True)
    temp.mkdir(exist_ok=True)
    env.update(HOME=str(home), USERPROFILE=str(home), TEMP=str(temp), TMP=str(temp), TMPDIR=str(temp),
               CI="1", DO_NOT_TRACK="1", QWEN_SKIP_PREPARE="1", QWEN_DESKTOP_DISABLE_UPDATES="1",
               COREPACK_HOME=str(home / "corepack"), npm_config_cache=str(home / "npm-cache"),
               npm_config_userconfig=os.devnull, UV_CACHE_DIR=str(home / "uv-cache"),
               PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="1", PUPPETEER_SKIP_DOWNLOAD="1",
               CARGO_BUILD_JOBS="1", PYTHONDONTWRITEBYTECODE="1")
    # rustup needs its existing compiler, not a fresh toolchain in the private HOME.
    env.setdefault("RUSTUP_HOME", str(Path.home() / ".rustup"))
    env.setdefault("CARGO_HOME", str(Path.home() / ".cargo"))
    return env


def run(args, cwd, env):
    print("Befehl:", " ".join(map(str, args)), flush=True)
    # Capture and print both streams so the current operation log contains build errors.
    result = subprocess.run(list(map(str, args)), cwd=cwd, env=env, capture_output=True,
                            text=True, errors="replace", timeout=7200)
    for output in (result.stdout, result.stderr):
        if output:
            print(output, flush=True)
    result.check_returncode()
    return result.stdout.strip()


def executable(name):
    value = shutil.which(name)
    if not value:
        raise ValueError(name + " fehlt; Basiswerkzeug separat einrichten. Siehe docs/tools/github-gap-tools.md.")
    return value


def node_command(name):
    node = executable("node")
    launcher = Path(executable(name)).resolve()
    if os.name != "nt":
        return [str(launcher)]
    candidates = [launcher.parent / "node_modules" / name / ("bin/npm-cli.js" if name == "npm" else "dist/corepack.js")]
    for candidate in candidates:
        if candidate.is_file():
            return [node, str(candidate)]
    raise ValueError("Native " + name + "-JS-CLI fehlt neben node.exe; keine unsichere cmd/Shell-Ausweichroute.")


def qwen_build(runtime, env):
    if platform.system() not in ("Linux", "Windows"):
        raise ValueError("Dieser Buildweg unterstuetzt Linux und natives Windows.")
    node = executable("node")
    if not run([node, "--version"], runtime, env).startswith("v22."):
        raise ValueError("Der gepinnte Desktop-Build benoetigt Node 22 gemaess .nvmrc.")
    executable("cargo")
    executable("rustc")
    executable("tar")
    if Path("/proc/meminfo").is_file():
        memory = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
        if int(memory["MemAvailable"].split()[0]) < 6 * 1024**2:
            raise ValueError("Qwen-Desktop-Build: mindestens 6 GiB verfuegbarer RAM erforderlich.")
    npm, corepack = node_command("npm"), node_command("corepack")
    if platform.system() == "Linux":
        run([executable("pkg-config"), "--exists", "webkit2gtk-4.1", "gtk+-3.0", "librsvg-2.0"], runtime, env)
    else:
        executable("cl")  # Run from the VS Developer PowerShell, not WSL cross-compilation.
    desktop = runtime / "packages/desktop"
    run(corepack + ["pnpm", "install", "--frozen-lockfile", "--prefer-offline", "--reporter=append-only"], runtime, env)
    run(npm + ["ci", "--workspaces=false", "--no-audit"], desktop, env)
    run(npm + ["run", "build:runtime", "--workspaces=false"], desktop, env)
    # Local unsigned executable: do not need or request upstream release signing keys.
    run(npm + ["run", "tauri", "--workspaces=false", "--", "build", "--no-bundle"], desktop, env)
    entry = "packages/desktop/src-tauri/target/release/qwen-code-desktop" + (".exe" if os.name == "nt" else "")
    return [entry, "packages/desktop/runtime/qwen-code/manifest.json"]


def hermes_build(runtime, env):
    python = os.environ.get("HERMES_PYTHON_BIN") or executable("python3.14" if os.name != "nt" else "python")
    run([python, "-I", "-c", "import sys,ssl; assert sys.version_info[:2] == (3,14), 'Hermes-Pin braucht Python 3.14'"], runtime, env)
    run([executable("uv"), "sync", "--frozen", "--no-dev", "--no-default-groups",
         "--no-python-downloads", "--python", python], runtime, env)
    vpython = runtime / ".venv" / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
    run([vpython, "-I", "-c", "import importlib.metadata as m; assert m.version('hermes-agent')"], runtime, env)
    return [".venv/Scripts/hermes.exe" if os.name == "nt" else ".venv/bin/hermes", "pyproject.toml"]


def validate(runtime, marker, spec, full=False):
    record = json.loads(checked(marker).read_text(encoding="utf-8"))
    if record.get("pin") != spec["pin"] or record.get("repo") != spec["repo"] or record.get("mode") != spec["mode"]:
        raise ValueError("Unbekannter Installationsnachweis; kein Ueberschreiben/Loeschen.")
    checked(runtime)
    if git(runtime, "rev-parse", "HEAD") != spec["pin"] or git(runtime, "remote", "get-url", "origin") != "https://github.com/" + spec["repo"] + ".git":
        raise ValueError("Fremder Quellbestand.")
    entries = record.get("entries", [])
    if not entries:
        raise ValueError("Keine geprueften Artefakte registriert.")
    for name in entries:
        relative = Path(name)
        if relative.is_absolute() or ".." in relative.parts or "\\" in name or ":" in name:
            raise ValueError("Unsicherer Artefaktpfad.")
        path = checked(runtime / relative)
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != record.get("files", {}).get(name):
            raise ValueError("Installationsartefakt fehlt oder wurde veraendert: " + name)
    if full and inventory(runtime) != record.get("files"):
        raise ValueError("Dateien geaendert/ergaenzt; vor Deinstallation sichern, nichts entfernt.")
    return record


def install(runtime, marker, base, spec):
    if marker.exists():
        validate(runtime, marker, spec)
        print("Gepinnter Bestand geprueft; kein automatisches latest-Upgrade.")
        return
    if runtime.exists():
        raise ValueError("Vorhandener Ordner ohne Besitznachweis; nichts ueberschrieben.")
    reserve(base, spec)
    runtime.mkdir(mode=0o700)
    try:
        git(runtime, "init", "--initial-branch=main")
        git(runtime, "remote", "add", "origin", "https://github.com/" + spec["repo"] + ".git")
        git(runtime, "fetch", "--depth=1", "origin", spec["pin"])
        git(runtime, "checkout", "--detach", "FETCH_HEAD")
        if git(runtime, "rev-parse", "HEAD") != spec["pin"]:
            raise ValueError("GitHub-Pin stimmt nicht.")
        entries = [".git/HEAD"]
        if spec["mode"] == "source":
            entries += [p.name for p in runtime.iterdir()
                        if p.is_file() and p.name.lower().startswith(("readme", "license", "copying"))]
            if len(entries) < 2:
                raise ValueError("Quellcheckout enthaelt keine README/Lizenzdatei.")
        if spec["mode"] != "source":
            env = build_env(runtime)
            entries = qwen_build(runtime, env) if spec["mode"] == "desktop-build" else hermes_build(runtime, env)
        for name in entries:
            if not checked(runtime / name).is_file():
                raise ValueError("Erwartetes Artefakt fehlt: " + name)
        record = dict(repo=spec["repo"], pin=spec["pin"], mode=spec["mode"], entries=entries,
                      installed=True, runtime_tested=False, files=inventory(runtime))
        with marker.open("x", encoding="utf-8") as stream:
            json.dump(record, stream)
        print("Installationsumfang:", spec["mode"], "Ziel:", runtime)
        print("Keine GUI/Agenten, Anmeldung, Modelle, Dienste oder Docker gestartet.")
        if spec["mode"] == "source":
            print("NUR QUELLEN installiert; KEINE gebaute/einsatzbereite Anwendung oder ComfyUI-Integration.")
    except BaseException:
        # This directory was absent before this invocation; venv paths stay stable, no rename.
        shutil.rmtree(checked(runtime))
        marker.unlink(missing_ok=True)
        print("Rollback: nur neue Dateien dieses Versuchs entfernt; Logs/Basiswerkzeuge bleiben.")
        raise


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=SPECS)
    parser.add_argument("action", nargs="?", default="install", choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    override = parser.add_mutually_exclusive_group()
    for action in ("repair", "uninstall", "status", "check"):
        override.add_argument("--" + action, dest="override", action="store_const", const=action)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen.")
        opts.action = opts.override
    spec = SPECS[opts.tool]
    base, runtime, marker = paths(opts.tool)
    if opts.dry_run or opts.action == "plan":
        print(json.dumps(dict(tool=opts.tool, **spec, target=str(runtime)), indent=2))
        print("Nur Plan; kein Download/Build/Docker/Start.")
        return 0
    if opts.action in ("status", "check", "doctor"):
        ready = False
        try:
            validate(runtime, marker, spec, full=opts.action == "doctor")
            ready = True
        except (ValueError, OSError, subprocess.SubprocessError, KeyError, TypeError):
            pass
        print(json.dumps(dict(installed=ready, scope=spec["mode"], runtime_tested=False)))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool=spec["name"]):
        print("GitHub:", spec["repo"], "Pin:", spec["pin"], "Umfang:", spec["mode"])
        if opts.action == "uninstall":
            if runtime.exists() or marker.exists():
                validate(runtime, marker, spec, full=True)
                shutil.rmtree(checked(runtime))
                marker.unlink()
            print("Privater unveraenderter Bestand entfernt; Nutzerdaten ausserhalb, Logs und Basiswerkzeuge bleiben.")
        else:
            install(runtime, marker, base, spec)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError, KeyError, TypeError) as error:
        print("GitHub-Tool fehlgeschlagen:", error, file=sys.stderr)
        sys.exit(1)
