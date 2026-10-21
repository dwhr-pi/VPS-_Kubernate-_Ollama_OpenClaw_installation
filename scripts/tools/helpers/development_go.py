"""Pinned private GitHub Go builds; never starts the resulting application."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import stat
import subprocess
import sys
import tempfile

from find_skills import checked, operation, resources
from offload_sources import fetch, verify

ROOT = Path(__file__).resolve().parents[3]
TOOLS = {row["id"]: row for row in json.loads(
    (ROOT / "config/development_go_tools.json").read_text(encoding="utf-8"))["tools"]}
for key, recipe in TOOLS.items():
    if (not re.fullmatch(r"[a-z0-9_]+", key) or not re.fullmatch(r"[0-9a-f]{40}", recipe["pin"]) or
            not re.fullmatch(r"https://github.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git", recipe["url"]) or
            not re.fullmatch(r"\d+\.\d+(?:\.\d+)?", recipe["go_min"]) or
            not re.fullmatch(r"[a-z0-9-]+", recipe["binary"]) or
            recipe["module_dir"] not in (".", "gopls") or
            not re.fullmatch(r"\.|\./cmd/[a-z0-9-]+", recipe["package"]) or
            any(Path(name).is_absolute() or ".." in Path(name).parts for name in recipe["files"])):
        raise ValueError("Ungueltiges gepinntes Go-Buildrezept.")


def paths(tool):
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluten externen User-Workspace angeben.")
    base = checked(raw / "tools" / tool)
    return base, checked(base / "source"), checked(base / "build-ready.json")


def digest(path):
    result = hashlib.sha256()
    with checked(path).open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024**2), b""):
            result.update(chunk)
    return result.hexdigest()


def installed(base, marker, spec):
    record = json.loads(marker.read_text(encoding="utf-8"))
    name = spec["binary"] + (".exe" if os.name == "nt" else "")
    binary = checked(base / name)
    if (record.get("commit") != spec["pin"] or record.get("binary") != name or
            record.get("scope") != "github-go-built" or record.get("application_tested") is not False or
            not binary.is_file() or record.get("sha256") != digest(binary)):
        raise ValueError("Build-Nachweis fehlt oder Binary veraendert; nichts ersetzen/loeschen.")
    return binary


def budget(base, spec):
    resources(base, base)
    if spec["heavy"] and os.environ.get("INSTALL_HEAVY_TOOLS") != "1":
        raise ValueError("Schwerer Build: bewusst INSTALL_HEAVY_TOOLS=1 setzen.")
    if shutil.disk_usage(base).free < spec["disk_mb"] * 1024**2:
        raise ValueError("Speicherplatzmangel: mindestens " + str(spec["disk_mb"]) + " MiB Ziel-Disk.")
    if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").is_dir():
        if shutil.disk_usage("/mnt/c").free < spec["disk_mb"] * 1024**2:
            raise ValueError("Speicherplatzmangel: Windows-C:-Reserve unterschritten.")
    if Path("/proc/meminfo").is_file():
        info = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
        if int(info["MemAvailable"].split()[0]) < spec["ram_mb"] * 1024:
            raise ValueError("Zu wenig RAM fuer den Build: mindestens " + str(spec["ram_mb"]) + " MiB.")


def build_env(job):
    env = {key: os.environ[key] for key in
           ("PATH", "SystemRoot", "SYSTEMROOT", "WINDIR", "COMSPEC", "PATHEXT", "LANG") if key in os.environ}
    for name in ("home", "cache", "modules", "tmp"):
        checked(job / name).mkdir(mode=0o700)
    env.update(HOME=str(job / "home"), USERPROFILE=str(job / "home"),
               TEMP=str(job / "tmp"), TMP=str(job / "tmp"), TMPDIR=str(job / "tmp"),
               GOCACHE=str(job / "cache"), GOMODCACHE=str(job / "modules"),
               GOPATH=str(job / "home" / "go"), GOENV="off", GOTOOLCHAIN="local",
               GOWORK="off", GOFLAGS="", CGO_ENABLED="0", GOMAXPROCS="2",
               GOPROXY="https://proxy.golang.org", GOSUMDB="sum.golang.org",
               GONOSUMDB="", GONOPROXY="", GOPRIVATE="", GOINSECURE="")
    return env


def run(command, cwd, env, capture=False, timeout=1800):
    kwargs = {"capture_output": True, "text": True} if capture else {
        "stdout": sys.stdout.log, "stderr": subprocess.STDOUT}
    try:
        return subprocess.run(command, cwd=cwd, env=env, check=True, timeout=timeout, **kwargs)
    except (OSError, subprocess.SubprocessError):
        raise ValueError("Go-Buildphase fehlgeschlagen/Zeitlimit; siehe aktuelles Log. Kein Systemumbau.") from None


def version_tuple(value):
    parts = [int(part) for part in value.split(".")]
    return tuple((parts + [0, 0])[:3])


def remove_job(job):
    def writable_retry(function, path, error):
        # Go's module cache is read-only on Windows. Only our new job directory
        # is disposable; no recursive chmod of existing user trees.
        os.chmod(path, stat.S_IWRITE | stat.S_IREAD)
        function(path)
    shutil.rmtree(checked(job), onerror=writable_retry)


def install(base, source, marker, spec):
    if marker.exists():
        installed(base, marker, spec)
        verify(source, spec)
        print("Bereits gebaut; Update bleibt am festen Pin.")
        return
    target = checked(base / (spec["binary"] + (".exe" if os.name == "nt" else "")))
    if target.exists():
        raise ValueError("Binary ohne Besitznachweis vorhanden; nicht ueberschreiben.")
    budget(base, spec)
    go = shutil.which(os.environ.get("DEV_GO_BIN", "go"))
    if not go:
        raise ValueError("Go fehlt; vorhandene Toolchain via DEV_GO_BIN waehlen. Kein automatischer Toolchain-Download.")
    job = checked(Path(tempfile.mkdtemp(prefix="build-job-", dir=base)))
    published = False
    moved = False
    try:
        env = build_env(job)
        version = run([go, "version"], job, env, capture=True, timeout=30).stdout
        match = re.search(r"\bgo([0-9]+\.[0-9]+(?:\.[0-9]+)?)\b", version)
        if not match or version_tuple(match.group(1)) < version_tuple(spec["go_min"]):
            raise ValueError("Vorhandenes Go ist zu alt/unbekannt. Minimum am Pin: " + spec["go_min"])
        print("Toolchain:", version.strip())
        fetch(base, source, spec)
        build_source = job / "source"
        shutil.copytree(source, build_source, symlinks=True, ignore=shutil.ignore_patterns(".git"))
        cwd = checked(build_source / spec["module_dir"])
        output = job / target.name
        run([go, "mod", "download"], cwd, env)
        run([go, "mod", "verify"], cwd, env)
        run([go, "build", "-mod=readonly", "-trimpath", "-buildvcs=false", "-p=2",
             "-o", str(output), spec["package"]], cwd, env)
        if not output.is_file() or output.stat().st_size == 0:
            raise ValueError("Go hat keine nutzbare Binary-Datei erzeugt.")
        metadata = run([go, "version", "-m", str(output)], job, env, capture=True, timeout=30).stdout
        if "\tpath\t" not in metadata:
            raise ValueError("Go-Buildmetadaten fehlen; kein Erfolgsmarker.")
        verify(source, spec)
        # Publish without overwriting a file created externally during a build.
        os.link(output, target)
        moved = True
        remove_job(job)
        job = None
        record = {"commit": spec["pin"], "binary": target.name, "sha256": digest(target),
                  "scope": "github-go-built", "application_tested": False}
        fd, pending = tempfile.mkstemp(prefix="marker-", dir=base)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as stream:
                json.dump(record, stream)
            os.replace(pending, marker)
            published = True
        finally:
            Path(pending).unlink(missing_ok=True)
        print("GitHub-Binary gebaut und Buildmetadaten geprueft:", target)
        print("Kein Toolstart, Debugging, Projektlauf, Plugin-Download oder Cluster-/Cloudzugriff.")
    finally:
        if moved and not published:
            target.unlink(missing_ok=True)
        if job is not None:
            remove_job(job)
        if not published:
            print("Rollback: nur neuer Buildjob/neue Binary entfernt; Quellen und Log bleiben erhalten.")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=TOOLS)
    parser.add_argument("action", nargs="?", default="install",
                        choices=("install", "update", "repair", "uninstall", "check", "doctor", "status", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    modes = parser.add_mutually_exclusive_group()
    for action in ("check", "repair", "uninstall", "status"):
        modes.add_argument("--" + action, dest="override", action="store_const", const=action)
    args = parser.parse_args(argv)
    if args.override:
        if args.action not in ("install", args.override):
            parser.error("Widerspruechliche Aktionen; keine Aenderung.")
        args.action = args.override
    spec = TOOLS[args.tool]
    base, source, marker = paths(args.tool)
    if args.dry_run or args.action == "plan":
        print(spec["name"], spec["url"], "Pin:", spec["pin"], "Ziel:", base)
        print("Go >=", spec["go_min"], "Disk/RAM MiB:", spec["disk_mb"], spec["ram_mb"], "Heavy:", spec["heavy"])
        print("Nur Buildplan; kein Download, Docker, Toolstart oder globaler PATH-Eintrag.")
        return 0
    if args.action in ("check", "doctor", "status"):
        ready = False
        try:
            installed(base, marker, spec)
            verify(source, spec)
            ready = True
        except (OSError, ValueError, subprocess.SubprocessError):
            pass
        print(json.dumps({"installed": ready, "application_tested": False}))
        return 0 if ready or args.action == "status" else 1
    with operation(base, args.action, tool=spec["name"]):
        print("Quelle:", spec["url"], "Pin:", spec["pin"], "Version:", spec["tag"])
        if args.action == "uninstall":
            if marker.exists():
                binary = installed(base, marker, spec)
                marker.unlink()
                binary.unlink()
            print("Eigene unveraenderte Binary entfernt; Quellcache, Go und Logs bleiben erhalten.")
        else:
            install(base, source, marker, spec)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        print("Development-Go:", exc, file=sys.stderr)
        sys.exit(1)
