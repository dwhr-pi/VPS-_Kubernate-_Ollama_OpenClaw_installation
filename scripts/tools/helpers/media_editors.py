"""Private GitHub media tools: Concat AppImage, Remotion/HyperFrames source builds."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile

from find_skills import checked, git, operation
from webinar_releases import download, reserve


SPECS = {
    "concat": {
        "name": "Concat", "repo": "jub0t/Concat", "version": "0.2.8", "reserve_mb": 2048,
        "license": "AGPL-3.0-or-later",
        "assets": {
            "x86_64": ("Concat-0.2.8-x86_64.AppImage", 137947640,
                       "4e64a3826cdb86be43fc82beeb087ecb82141ea5c557f156d855fd21ff87ccb1"),
            "aarch64": ("Concat-0.2.8-aarch64.AppImage", 121305608,
                        "93058c09134bea4f274ea6c9578b7cda638ab81ebe4db2841b03a71f47d9e785"),
        },
        "entry": "Concat.AppImage", "artifacts": ("Concat.AppImage",),
    },
    "remotion": {
        "name": "Remotion", "repo": "remotion-dev/remotion", "version": "4.0.538",
        "pin": "3ab34665c49279cc35820275380983068bb1bbf9", "reserve_mb": 16384,
        "license": "Remotion License", "bun": "1.4.3",
        "entry": "packages/cli/remotion-cli.js",
        "artifacts": ("packages/cli/remotion-cli.js", "packages/cli/dist/index.js",
                      "packages/core/dist/cjs/index.js", "node_modules/.bin/turbo"),
        "license_file": "LICENSE.md",
    },
    "hyperframes": {
        "name": "HyperFrames", "repo": "heygen-com/hyperframes", "version": "0.8.186",
        "pin": "3d67fb9d10a864201db9de3214f8cd67fb6fec46", "reserve_mb": 12288,
        "license": "Apache-2.0", "bun": "1.4.4",
        "entry": "packages/cli/bin/hyperframes.mjs",
        "artifacts": ("packages/cli/bin/hyperframes.mjs", "packages/cli/dist/cli.js",
                      "packages/cli/dist/runtimeVersion.js", "packages/core/dist/index.js"),
        "license_file": "LICENSE",
        "packages": ("parsers", "lint", "studio-server", "core", "engine", "producer",
                     "player", "studio", "shader-transitions", "aws-lambda", "gcp-cloud-run",
                     "sdk", "inspector", "cli"),
    },
}


def paths(key):
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluter externer User-Workspace erforderlich.")
    base = checked(raw / "tools" / key)
    return base, checked(base / "runtime"), checked(base / "build-ready.json")


def digest(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def safe_entry(runtime, relative):
    part = Path(relative)
    if part.is_absolute() or ".." in part.parts or "\\" in relative or ":" in relative:
        raise ValueError("Unsicherer Besitznachweis.")
    target = runtime / part
    if not target.resolve().is_relative_to(runtime.resolve()):
        raise ValueError("Datei/Link verlaesst private Runtime.")
    return target


def inventory(runtime):
    records = {}
    for path in sorted(runtime.rglob("*")):
        relative = path.relative_to(runtime).as_posix()
        if len(records) >= 150000:
            raise ValueError("Dateigrenze fuer private Runtime ueberschritten.")
        safe_entry(runtime, relative)
        if path.is_symlink():
            records[relative] = "link:" + os.readlink(path)
        elif path.is_file():
            records[relative] = digest(path)
        elif not path.is_dir():
            raise ValueError("Spezialdatei in Runtime; keine automatische Entfernung.")
    return records


def run(args, cwd, timeout=1800):
    allow = {"PATH", "SYSTEMROOT", "SystemRoot", "TEMP", "TMP", "TMPDIR", "SHELL",
             "COMSPEC", "PATHEXT", "LANG", "LC_ALL", "LD_LIBRARY_PATH"}
    env = {**{key: value for key, value in os.environ.items() if key in allow},
           "HOME": str(cwd / ".installer-home"), "CI": "1", "PYTHONDONTWRITEBYTECODE": "1",
           "XDG_CONFIG_HOME": str(cwd / ".installer-home/config"), "npm_config_userconfig": os.devnull,
           "PUPPETEER_SKIP_DOWNLOAD": "1", "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD": "1",
           "TURBO_TELEMETRY_DISABLED": "1", "DO_NOT_TRACK": "1",
           "BUN_INSTALL_CACHE_DIR": str(cwd / ".installer-cache"),
           "NODE_OPTIONS": "--max-old-space-size=3072", "UV_THREADPOOL_SIZE": "1"}
    print("Befehl:", " ".join(map(str, args)), flush=True)
    subprocess.run(list(map(str, args)), cwd=cwd, env=env, check=True, timeout=timeout)


@contextmanager
def build_lock(base):
    lock = checked(base.parent / "media-build.lock")
    try:
        lock.mkdir(mode=0o700)
    except FileExistsError as error:
        raise ValueError("Ein Medienbuild laeuft bereits oder ein alter Lock muss manuell geprueft werden.") from error
    try:
        yield
    finally:
        lock.rmdir()


def runtimes(spec):
    node, bun = shutil.which("node"), shutil.which("bun")
    if not node or not bun:
        raise ValueError("Vorhandenes Node >=22 und Bun " + spec["bun"] +
                         " erforderlich; keine globale Laufzeitinstallation. Siehe Tool-Dokumentation.")
    for executable, expected in ((node, None), (bun, spec["bun"])):
        probe = subprocess.run([executable, "--version"], capture_output=True, text=True, check=True, timeout=15)
        version = probe.stdout.strip().lstrip("v")
        if (expected and version != expected) or (not expected and int(version.split(".")[0]) < 22):
            raise ValueError("Nicht passende Laufzeit: " + executable + " " + version)
    if Path("/proc/meminfo").is_file():
        available = next(line for line in Path("/proc/meminfo").read_text().splitlines()
                         if line.startswith("MemAvailable:"))
        if int(available.split()[1]) < 4 * 1024**2:
            raise ValueError("Source-Build braucht mindestens 4 GiB verfuegbaren RAM.")
    return node, bun


def fetch(stage, spec):
    url = "https://github.com/" + spec["repo"] + ".git"
    git(stage, "init", "--initial-branch=main")
    git(stage, "remote", "add", "origin", url)
    git(stage, "fetch", "--depth=1", "origin", spec["pin"])
    git(stage, "checkout", "--detach", "FETCH_HEAD")
    if git(stage, "rev-parse", "HEAD") != spec["pin"] or git(stage, "remote", "get-url", "origin") != url:
        raise ValueError("GitHub-Pin/Origin nicht passend.")
    for name in (spec["license_file"], "package.json", "bun.lock", "packages/cli/package.json"):
        if not checked(stage / name).is_file():
            raise ValueError("Gepinnter Quellbestand unvollstaendig: " + name)
    manifest = json.loads((stage / "packages/cli/package.json").read_text(encoding="utf-8"))
    if manifest.get("version") != spec["version"]:
        raise ValueError("Quellversion entspricht nicht dem Pin.")


def license_gate(stage, spec, accepted):
    print((stage / spec["license_file"]).read_text(encoding="utf-8"))
    if accepted or (sys.stdin.isatty() and
                    input("Remotion-Lizenz akzeptieren? [(j)a/(N)ein]: ").strip().lower() == "j"):
        return
    raise ValueError("Remotion-Lizenz nicht akzeptiert; keine Pakete installiert. --accept-license bewusst setzen.")


def validate(runtime, marker, spec, full=False):
    data = json.loads(checked(marker).read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("repo") != spec["repo"] or data.get("version") != spec["version"] or data.get("pin") != spec.get("pin") or data.get("build_ready") is not True:
        raise ValueError("Unbekannter Installationsnachweis.")
    checked(runtime)
    for name in spec["artifacts"]:
        path = safe_entry(runtime, name)
        if not path.is_file() or not path.stat().st_size:
            raise ValueError("Build-Artefakt fehlt: " + name)
        recorded = data.get("hashes", {}).get(name)
        actual = "link:" + os.readlink(path) if path.is_symlink() else digest(path)
        if recorded != actual:
            raise ValueError("Build-Artefakt veraendert: " + name)
    if full and inventory(runtime) != data.get("hashes"):
        raise ValueError("Runtime veraendert oder Zusatzdateien vorhanden; erst sichern. Nichts geloescht.")
    return data


def install(key, base, runtime, marker, spec, accepted=False):
    if marker.exists():
        validate(runtime, marker, spec, full=True)
        print("Gepinnte Installation geprueft; kein latest-Upgrade.")
        return
    if runtime.exists():
        raise ValueError("Runtime ohne Besitznachweis; nicht ueberschrieben oder geloescht.")
    if platform.system() != "Linux":
        raise ValueError("Dieser Installer richtet Linux/Ubuntu/WSL ein; native Desktop-Wege siehe Dokumentation.")
    reserve(base, spec)
    node, bun = runtimes(spec) if key != "concat" else (None, None)
    stage = Path(tempfile.mkdtemp(prefix="media-stage-", dir=base))
    published = False
    try:
        if key == "concat":
            machine = {"amd64": "x86_64", "arm64": "aarch64"}.get(platform.machine().lower(), platform.machine().lower())
            if machine not in spec["assets"]:
                raise ValueError("Kein gepinntes Concat-AppImage fuer diese Architektur.")
            name, size, sha = spec["assets"][machine]
            url = f"https://github.com/{spec['repo']}/releases/download/v{spec['version']}/{name}"
            print("Download:", url, "Bytes:", size, "SHA256:", sha)
            download(url, stage / spec["entry"], size, sha)
            (stage / spec["entry"]).chmod(0o755)
        else:
            fetch(stage, spec)
            if key == "remotion":
                license_gate(stage, spec, accepted)
            (stage / ".installer-home").mkdir()
            run([bun, "install", "--frozen-lockfile", "--ignore-scripts"], stage)
            reserve(base, spec)
            if key == "remotion":
                run([bun, "run", "build", "--concurrency=1", "--filter=@remotion/cli..."], stage, 3600)
            else:
                for package in spec["packages"]:
                    run([bun, "run", "--cwd", "packages/" + package, "build"], stage, 900)
            for name in spec["artifacts"]:
                path = safe_entry(stage, name)
                if not path.is_file() or not path.stat().st_size:
                    raise ValueError("Build liefert erwartetes Artefakt nicht: " + name)
            run([node, "--check", stage / spec["entry"]], stage, 30)
            cache = checked(stage / ".installer-cache")
            if cache.exists():
                shutil.rmtree(cache)
        hashes = inventory(stage)
        record = {"repo": spec["repo"], "version": spec["version"], "pin": spec.get("pin"),
                  "build_ready": True, "runtime_ready": False, "service_started": False,
                  "scope": "github-release" if key == "concat" else "github-source-build",
                  "entry": spec["entry"], "hashes": hashes}
        stage.rename(runtime)
        published = True
        fd, pending = tempfile.mkstemp(prefix="media-status-", dir=base)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as stream:
                json.dump(record, stream, indent=2)
            os.replace(pending, marker)
        finally:
            Path(pending).unlink(missing_ok=True)
        print(spec["name"], "installiert:", runtime / spec["entry"])
        print("Paket/Build geprueft; runtime_ready=false bis zum separaten GUI-/Render-/Codec-Test.")
        print("Kein Docker, globaler PATH, Browser-/Modell-/Agenten-/MCP-/Cloud- oder Dienststart.")
    except Exception:
        if published and not marker.exists():
            shutil.rmtree(checked(runtime))
        print("Rollback: nur neue Dateien dieses Installationsversuchs entfernt; bestehende Daten bleiben.")
        raise
    finally:
        if stage.exists():
            shutil.rmtree(checked(stage))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=SPECS)
    parser.add_argument("action", nargs="?", default="install", choices=("install", "repair", "update", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--accept-license", action="store_true")
    overrides = parser.add_mutually_exclusive_group()
    for action in ("repair", "uninstall", "check", "status"):
        overrides.add_argument("--" + action, dest="override", action="store_const", const=action)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen.")
        opts.action = opts.override
    spec = SPECS[opts.tool]
    base, runtime, marker = paths(opts.tool)
    if opts.dry_run or opts.action == "plan":
        print(spec["name"], spec["version"], "https://github.com/" + spec["repo"], spec.get("pin", "GitHub-Release v" + spec["version"]))
        print("Ziel:", runtime, "Reserve MiB:", spec["reserve_mb"], "Lizenz:", spec["license"])
        print("Bun:", spec.get("bun", "nicht benoetigt"), "Nur Plan; keine Downloads, Builds oder Starts.")
        return 0
    if opts.action in ("status", "check", "doctor"):
        ready = False
        try:
            validate(runtime, marker, spec, full=opts.action == "doctor")
            ready = True
        except (ValueError, OSError, KeyError, TypeError):
            pass
        print(json.dumps({"installed": ready, "build_ready": ready, "runtime_ready": False, "service_started": False}))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool=spec["name"]):
        print("Quelle:", spec["repo"], "Version:", spec["version"], "Pin:", spec.get("pin"))
        if opts.action == "uninstall":
            if runtime.exists() or marker.exists():
                validate(runtime, marker, spec, full=True)
                shutil.rmtree(checked(runtime))
                marker.unlink()
            print("Unveraenderte private Runtime entfernt; Projekte ausserhalb der Runtime, Modelle, Basiswerkzeuge und Logs bleiben.")
        else:
            with build_lock(base):
                install(opts.tool, base, runtime, marker, spec, opts.accept_license)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print("Medien-Installation fehlgeschlagen:", error, "Aktuelles Operationslog pruefen.", file=sys.stderr)
        sys.exit(1)
