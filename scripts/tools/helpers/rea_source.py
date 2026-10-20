"""REA source preparation/build only: never runs setup, MCP or an analysis target."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

from find_skills import checked, git, operation, resources

URL = "https://github.com/morluto/rea.git"
PIN = "1629266e3c08c90fed6bba5383528af7986a12b7"
VERSION = "6.7.0"
ARTIFACTS = ("dist/mcp/main.js", "dist/cli-runtime/cli.js",
             "dist/cli-runtime/cliOutput.js", "dist/cli-runtime/cliResultOutput.js")


def paths():
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluten externen User-Workspace angeben, nicht Dateisystemwurzel.")
    base = checked(raw / "tools/rea")
    return base, checked(base / "source"), checked(base / "source-ready.json")


def source_ok(source):
    checked(source / ".git")
    if (git(source, "rev-parse", "HEAD") != PIN or
            git(source, "remote", "get-url", "origin") != URL or
            git(source, "status", "--porcelain", "--untracked-files=all")):
        raise ValueError("REA-Quelle fremd/veraendert; kein Reset oder main-Upgrade.")
    for name in ("package.json", "package-lock.json", "LICENSE", "DISCLAIMER.md", "scripts/rea.mjs"):
        if not checked(source / name).is_file():
            raise ValueError("REA-Quellbestand unvollstaendig: " + name)
    package = json.loads((source / "package.json").read_text(encoding="utf-8"))
    if package.get("name") != "rea-agents" or package.get("version") != VERSION:
        raise ValueError("Unerwartetes REA-Paket.")


def fetch(base, source):
    if source.exists():
        source_ok(source)
        return
    stage = Path(tempfile.mkdtemp(prefix="rea-download-", dir=base))
    try:
        git(stage, "init", "--initial-branch=main")
        git(stage, "remote", "add", "origin", URL)
        git(stage, "fetch", "--depth=1", "origin", PIN)
        git(stage, "checkout", "--detach", "FETCH_HEAD")
        source_ok(stage)
        stage.rename(source)
    finally:
        if stage.exists() and checked(stage).parent == checked(base):
            shutil.rmtree(stage)


def artifact_hashes(source):
    return {name: hashlib.sha256(checked(source / name).read_bytes()).hexdigest()
            for name in ARTIFACTS}


def record_ok(source, marker):
    data = json.loads(marker.read_text(encoding="utf-8"))
    if data.get("commit") != PIN or data.get("scope") not in ("github-source", "github-source-built"):
        raise ValueError("Unbekannter REA-Marker; erst manuell pruefen.")
    if data["scope"] == "github-source-built" and data.get("hashes") != artifact_hashes(source):
        raise ValueError("Build-Dateien fehlen oder wurden veraendert.")
    return data


def resource_guard(base, build=False):
    resources(base, base)
    required = (8192 if build else 1024) * 1024**2
    if shutil.disk_usage(base).free < required:
        raise ValueError("Speicherplatzmangel: REA braucht " + str(required // 1024**2) + " MiB Disk-Reserve.")
    if build and Path("/proc/meminfo").is_file():
        info = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
        if int(info["MemAvailable"].split()[0]) < 2048 * 1024:
            raise ValueError("REA-Build: mindestens 2 GiB aktuell verfuegbaren RAM freimachen.")
    if build and os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").is_dir():
        if shutil.disk_usage("/mnt/c").free < required:
            raise ValueError("Windows-C:-Speicherplatzmangel: REA-Build braucht 8 GiB Reserve.")


def run_command(command, source, **kwargs):
    return subprocess.run(command, cwd=source, check=True, **kwargs)


def build_source(source):
    if os.environ.get("INSTALL_HEAVY_TOOLS") != "1":
        raise ValueError("REA_BUILD=1 braucht zusaetzlich INSTALL_HEAVY_TOOLS=1.")
    if sys.platform == "win32":
        raise ValueError("Automatischer REA-Build nur unter Linux/macOS; nativen Windows-Build nach Anleitung bewusst manuell ausfuehren.")
    node, npm = shutil.which("node"), shutil.which("npm")
    if not node or not npm:
        raise ValueError("Node/npm fehlt; keine automatische Systeminstallation.")
    # Keep credentials and inherited Node preloads out of runtime probes, too.
    keep = ("PATH", "HOME", "TMPDIR", "TMP", "TEMP", "LANG")
    env = {key: os.environ[key] for key in keep if key in os.environ}
    env.update(HUSKY="0", PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="1",
               PUPPETEER_SKIP_DOWNLOAD="1", TURBO_TELEMETRY_DISABLED="1",
               npm_config_audit="false", npm_config_fund="false",
               npm_config_userconfig=os.devnull, NODE_OPTIONS="--max-old-space-size=1536")
    version = run_command([node, "--version"], source, env=env, capture_output=True, text=True, timeout=15).stdout.strip()
    match = re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)", version)
    if not match:
        raise ValueError("Node-Version nicht eindeutig.")
    major, minor, _ = map(int, match.groups())
    if not (major == 22 and minor >= 19 or major == 24 and minor >= 11 or major >= 26):
        raise ValueError("REA braucht Node ^22.19.0 || ^24.11.0 || >=26.0.0.")
    npm_version = run_command([npm, "--version"], source, env=env, capture_output=True, text=True, timeout=15).stdout.strip()
    if npm_version != "11.16.0":
        raise ValueError("REA-Source-Build erwartet vorhandenes npm 11.16.0.")
    print("Build-Ausgabe im aktuellen Log; Timeout je Phase 3600s. Keine Agentenaktivierung.")
    for args in (["ci", "--ignore-scripts", "--no-audit", "--no-fund"], ["run", "build:cached", "--", "--concurrency=1"]):
        print("REA-Buildphase:", " ".join(args))
        run_command([npm, *args], source, env=env, timeout=3600,
                    stdout=sys.stdout.log, stderr=subprocess.STDOUT)
    return artifact_hashes(source)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", nargs="?", default="install",
                        choices=("install", "update", "repair", "uninstall", "check", "doctor", "status", "plan"))
    args = list(sys.argv[1:] if argv is None else argv)
    if "--dry-run" in args:
        args = ["plan"]
    elif args:
        args[0] = {"--repair": "repair", "--uninstall": "uninstall",
                   "--check": "check", "--status": "status"}.get(args[0], args[0])
    mode = parser.parse_args(args).action
    base, source, marker = paths()
    if mode == "plan":
        print(URL, PIN, VERSION, "Ziel:", source)
        print("Standard: nur GitHub-Quellen; optional REA_BUILD=1 + INSTALL_HEAVY_TOOLS=1.")
        print("Kein setup, MCP, Hopper, Targetzugriff oder Docker. Logs/Quelle extern.")
        return 0
    if mode in ("status", "check", "doctor"):
        data = None
        try:
            source_ok(source)
            data = record_ok(source, marker)
        except (ValueError, OSError, subprocess.SubprocessError):
            pass
        print(json.dumps({"installed": data is not None, "scope": data["scope"] if data else "absent",
                          "mcp_configured": False, "runtime_tested": False}))
        return 0 if data or mode == "status" else 1
    with operation(base, mode, tool="REA"):
        print("GitHub-Quelle:", URL, "Pin:", PIN, "Paket:", VERSION)
        if mode == "uninstall":
            if marker.exists():
                # Only deactivate our known marker; never touch agent registrations.
                data = json.loads(marker.read_text(encoding="utf-8"))
                if data.get("commit") != PIN:
                    raise ValueError("Fremder Marker; nichts entfernt.")
                marker.unlink()
            print("REA-Setupregistrierung entfernt. Quellen, Build, Logs und manuelle MCP-Eintraege bleiben.")
            return 0
        build = os.environ.get("REA_BUILD", "0")
        if build not in ("0", "1"):
            raise ValueError("REA_BUILD muss 0 oder 1 sein.")
        resource_guard(base, build == "1")
        if build == "1" and os.environ.get("INSTALL_HEAVY_TOOLS") != "1":
            raise ValueError("Schwerer Build nur mit INSTALL_HEAVY_TOOLS=1.")
        fetch(base, source)
        if marker.exists():
            current = record_ok(source, marker)
            if build == "0" or current["scope"] == "github-source-built":
                print("Gepinnter REA-Stand bereits vorbereitet; kein Upgrade/Start.")
                return 0
        data = {"commit": PIN, "version": VERSION, "scope": "github-source"}
        if build == "1":
            if marker.exists():
                marker.unlink()
            try:
                data["hashes"] = build_source(source)
                source_ok(source)
            except Exception:
                print("Build fehlgeschlagen: kein Erfolgsmarker; Quellen/Teilbuild fuer Diagnose erhalten.")
                raise
            data["scope"] = "github-source-built"
        fd, temporary = tempfile.mkstemp(prefix="status-", dir=base)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as stream:
                json.dump(data, stream)
            os.replace(temporary, marker)
        finally:
            if Path(temporary).exists():
                Path(temporary).unlink()
        print("REA vorbereitet:", data["scope"], "; keine MCP-Registrierung oder Analyse ausgefuehrt.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("REA-Fehler:", error, file=sys.stderr)
        sys.exit(1)
