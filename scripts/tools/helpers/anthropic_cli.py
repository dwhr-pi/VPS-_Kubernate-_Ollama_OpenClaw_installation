"""Pinned GitHub build of ant; never executes the CLI, logs in or calls an API."""
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

from find_skills import checked, operation, resources
from offload_sources import fetch, verify

URL = "https://github.com/anthropics/anthropic-cli.git"
PIN = "78ab237474e7c34983d77f6f41fcd1152f32a7ce"
PACKAGE = "github.com/anthropics/anthropic-cli/cmd/ant"
SPEC = {"url": URL, "pin": PIN, "module": "cmd/ant/main.go",
        "files": ("LICENSE", "go.mod", "go.sum", "cmd/ant/main.go")}


def paths():
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluten externen User-Workspace angeben.")
    base = checked(raw / "tools/anthropic_cli")
    binary = checked(base / "bin" / ("ant.exe" if os.name == "nt" else "ant"))
    return base, checked(base / "source"), binary, checked(base / "build-ready.json")


def source_ok(source):
    verify(source, SPEC)
    module = (source / "go.mod").read_text(encoding="utf-8")
    if not re.search(r"(?m)^module github\.com/anthropics/anthropic-cli\s*$", module) or not re.search(r"(?m)^go 1\.25\s*$", module):
        raise ValueError("Unerwartetes Go-Modul/Go-Minimum am Pin.")


def digest(path):
    checked(path)
    checksum = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024**2), b""):
            checksum.update(chunk)
    return checksum.hexdigest()


def read_record(marker):
    if not marker.exists():
        return None
    data = json.loads(marker.read_text(encoding="utf-8"))
    if (not isinstance(data, dict) or data.get("commit") != PIN or
            data.get("scope") != "github-source-built" or data.get("api_tested") is not False or
            not re.fullmatch(r"[a-f0-9]{64}", str(data.get("binary_sha256", "")))):
        raise ValueError("Unbekannter Build-Marker; keine Dateien ueberschreiben/loeschen.")
    return data


def owned(binary, record, allow_missing=False):
    if not binary.exists() and allow_missing:
        return
    if not binary.is_file() or binary.stat().st_size == 0 or digest(binary) != record["binary_sha256"]:
        raise ValueError("CLI fehlt oder wurde lokal veraendert; keine fremde Datei ersetzen.")
    if os.name != "nt" and not os.access(binary, os.X_OK):
        raise ValueError("CLI ist nicht ausfuehrbar; Rechte bewusst pruefen.")


def build_env(base):
    # No inherited API keys, cloud credentials, Go overrides or global config.
    keep = ("PATH", "SystemRoot", "SYSTEMROOT", "WINDIR", "COMSPEC", "PATHEXT", "TEMP", "TMP", "TMPDIR", "LANG")
    env = {key: os.environ[key] for key in keep if key in os.environ}
    home = str(checked(base / "build-home"))
    temporary = str(checked(base / "build-temp"))
    env.update(HOME=home, USERPROFILE=home, GOENV="off", GOTOOLCHAIN="local", GOWORK="off",
               TEMP=temporary, TMP=temporary, TMPDIR=temporary,
               APPDATA=str(checked(base / "build-home/AppData/Roaming")),
               LOCALAPPDATA=str(checked(base / "build-home/AppData/Local")),
               XDG_CONFIG_HOME=str(checked(base / "build-home/.config")),
               GOPATH=str(checked(base / "go-cache")), GOCACHE=str(checked(base / "go-build-cache")),
               GOPROXY="https://proxy.golang.org", GOSUMDB="sum.golang.org", CGO_ENABLED="0",
               GOMAXPROCS="2", GOMEMLIMIT="768MiB", GOFLAGS="", GOTELEMETRY="off",
               AWS_EC2_METADATA_DISABLED="true", OTEL_SDK_DISABLED="true")
    return env


def run(go, args, source, env, capture=False, timeout=1800):
    options = {"capture_output": True, "text": True} if capture else {"stdout": sys.stdout.log, "stderr": subprocess.STDOUT}
    try:
        return subprocess.run([go, *args], cwd=source, env=env, check=True, timeout=timeout, **options)
    except (OSError, subprocess.SubprocessError):
        raise ValueError("Go-Pruefung/Build fehlgeschlagen oder Timeout; siehe aktuelles Log.") from None


def go_tool(base):
    go = shutil.which("go")
    if not go:
        raise ValueError("Go >=1.25 fehlt. Vorhandene Go-Toolchain separat einrichten; --source-only bereitet nur Quellen vor.")
    env = build_env(base)
    version = run(go, ["version"], base, env, capture=True, timeout=15).stdout.strip()
    match = re.fullmatch(r"go version go(\d+)\.(\d+)(?:\.\d+)? [a-z0-9]+/[a-z0-9]+", version)
    if not match or tuple(map(int, match.groups())) < (1, 25):
        raise ValueError("Dieser Pin braucht Go >=1.25; kein automatischer Toolchain-Download.")
    return go, env


def budget(base, source_only):
    resources(base, base)
    required = (1 if source_only else 4) * 1024**3
    if shutil.disk_usage(base).free < required:
        raise ValueError("Speicherplatzmangel: 1 GiB fuer Quellen bzw. 4 GiB fuer den Go-Build freihalten.")
    if not source_only and Path("/proc/meminfo").is_file():
        info = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
        if int(info["MemAvailable"].split()[0]) < 1024**2:
            raise ValueError("Go-Build braucht mindestens 1 GiB aktuell verfuegbaren RAM.")
    if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").is_dir() and shutil.disk_usage("/mnt/c").free < required:
        raise ValueError("Windows-C:-Speicherplatzmangel: Host-Reserve fuer diesen Schritt unterschritten.")


def publish(base, binary, marker, stage):
    record = {"commit": PIN, "scope": "github-source-built", "api_tested": False,
              "binary_sha256": digest(stage)}
    binary.parent.mkdir(mode=0o700, exist_ok=True)
    stage.chmod(0o700)
    os.replace(stage, binary)
    pending = None
    try:
        fd, pending = tempfile.mkstemp(prefix="build-record-", dir=base)
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            json.dump(record, stream)
        os.replace(pending, marker)
    except Exception:
        # Only the new artifact of this attempt, never sources, caches or old tools.
        if binary.is_file() and digest(binary) == record["binary_sha256"]:
            binary.unlink()
        raise
    finally:
        if pending and Path(pending).exists():
            Path(pending).unlink()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", nargs="?", default="install",
                        choices=("install", "update", "repair", "uninstall", "doctor", "check", "status", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--source-only", action="store_true")
    modes = parser.add_mutually_exclusive_group()
    for mode in ("repair", "uninstall", "check", "status"):
        modes.add_argument("--" + mode, dest="override", action="store_const", const=mode)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen.")
        opts.action = opts.override
    base, source, binary, marker = paths()
    if opts.dry_run or opts.action == "plan":
        print("Anthropic_CLI / ant:", opts.action, URL, PIN, "Ziel:", binary)
        print("Nur Quellen" if opts.source_only else "GitHub-Source-Build mit vorhandenem Go >=1.25; 4 GiB Disk-Reserve.")
        print("Kein Docker, Login, CLI-Start, API-Aufruf oder Modell-Download. Uninstall entfernt nur eigene CLI/Build-Marker.")
        return 0
    if opts.action in ("status", "check", "doctor"):
        ready = False
        try:
            record = read_record(marker)
            if record:
                source_ok(source)
                owned(binary, record)
                ready = True
        except (ValueError, OSError, subprocess.SubprocessError):
            pass
        print(json.dumps({"installed": ready, "scope": "github-source-built", "api_tested": False}))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool="Anthropic_CLI"):
        print("Quelle:", URL, "Pin:", PIN)
        record = read_record(marker)
        if record:
            owned(binary, record, allow_missing=opts.action in ("repair", "uninstall"))
        elif binary.exists():
            raise ValueError("CLI ohne passenden Besitznachweis vorhanden; bleibt unveraendert.")
        if opts.action == "uninstall":
            if record:
                if binary.exists():
                    binary.unlink()
                marker.unlink()
            print("Eigene CLI/Registrierung entfernt; Quellen, Go-Cache, Logs und Zugangsdaten bleiben erhalten.")
            return 0
        if record and binary.exists():
            source_ok(source)
            print("Gepinnte CLI bereits gebaut; kein latest-Upgrade oder API-Test.")
            return 0
        if record:
            marker.unlink()
        budget(base, opts.source_only)
        go, env = go_tool(base) if not opts.source_only else (None, None)
        fetch(base, source, SPEC)
        source_ok(source)
        if opts.source_only:
            print("Nur GitHub-Quellen vorbereitet. Kein Build-Marker, keine installierte CLI.")
            return 0
        Path(env["HOME"]).mkdir(mode=0o700, exist_ok=True)
        Path(env["TMPDIR"]).mkdir(mode=0o700, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix="build-stage-", dir=base) as temp:
            staged = checked(Path(temp) / binary.name)
            run(go, ["build", "-mod=readonly", "-trimpath", "-buildvcs=false", "-p=1", "-o", str(staged), "./cmd/ant"], source, env)
            run(go, ["mod", "verify"], source, env)
            info = run(go, ["version", "-m", str(staged)], source, env, capture=True, timeout=15).stdout
            if not re.search(r"\bpath\s+" + re.escape(PACKAGE) + r"(?:\s|$)", info):
                raise ValueError("Go-Buildinfo entspricht nicht der erwarteten ant-CLI.")
            if not staged.is_file() or staged.stat().st_size == 0:
                raise ValueError("Go hat kein nutzbares Build-Artefakt erzeugt.")
            source_ok(source)
            publish(base, binary, marker, staged)
        print("ant aus GitHub gebaut:", binary, "Keine CLI-Ausfuehrung/Authentifizierung/API-Abfrage.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as exc:
        print("Anthropic_CLI:", exc, file=sys.stderr)
        sys.exit(1)
