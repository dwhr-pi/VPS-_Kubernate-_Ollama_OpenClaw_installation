"""Optional pinned source checkouts; no Python packages, drivers or models installed."""
import argparse
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import subprocess
from find_skills import checked, git, operation, resources

TOOLS = {
    "hf_accelerate": {
        "name": "HF_Accelerate", "url": "https://github.com/huggingface/accelerate.git",
        "pin": "abe3749c6274b2ffc9a99cc57ca72ff8bca72ab8",
        "module": "src/accelerate/__init__.py",
    },
    "deepspeed": {
        "name": "DeepSpeed", "url": "https://github.com/deepspeedai/DeepSpeed.git",
        "pin": "3133d9d689a67ab1d4feebf8166f19ee28cace6a",
        "module": "deepspeed/__init__.py",
    },
}


def paths(key):
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluten externen User-Workspace angeben.")
    base = checked(raw / "tools" / key)
    return base, checked(base / "source"), checked(base / "source-ready.json")


def verify(source, spec):
    checked(source / ".git")
    if (git(source, "rev-parse", "HEAD") != spec["pin"] or
            git(source, "remote", "get-url", "origin") != spec["url"] or
            git(source, "status", "--porcelain", "--untracked-files=all")):
        raise ValueError("Fremde/veraenderte Quelle; kein Reset oder latest-Pull.")
    for name in ("LICENSE", "setup.py", spec["module"]):
        if not checked(source / name).is_file():
            raise ValueError("Quellbestand unvollstaendig: " + name)


def fetch(base, source, spec):
    if source.exists():
        verify(source, spec)
        return
    stage = Path(tempfile.mkdtemp(prefix="source-download-", dir=base))
    try:
        git(stage, "init", "--initial-branch=main")
        git(stage, "remote", "add", "origin", spec["url"])
        git(stage, "fetch", "--depth=1", "origin", spec["pin"])
        git(stage, "checkout", "--detach", "FETCH_HEAD")
        verify(stage, spec)
        stage.rename(source)
    finally:
        if stage.exists() and checked(stage).parent == checked(base):
            shutil.rmtree(stage)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=TOOLS)
    parser.add_argument("action", nargs="?", default="install",
                        choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    args = list(sys.argv[1:] if argv is None else argv)
    if "--dry-run" in args and args:
        args = [args[0], "plan"]
    elif len(args) > 1:
        args[1] = {"--check": "check", "--repair": "repair", "--uninstall": "uninstall",
                   "--status": "status"}.get(args[1], args[1])
    opts = parser.parse_args(args)
    spec = TOOLS[opts.tool]
    base, source, marker = paths(opts.tool)
    record = {"commit": spec["pin"], "scope": "github-source", "runtime_ready": False}
    if opts.action == "plan":
        print(spec["name"], spec["url"], spec["pin"], "Ziel:", source)
        print("Nur Quellen: keine pip-/Torch-/CUDA-/ROCm-/Modellinstallation. 1 GiB Disk-Reserve.")
        return 0
    if opts.action in ("status", "doctor", "check"):
        ready = False
        try:
            verify(source, spec)
            ready = json.loads(marker.read_text(encoding="utf-8")) == record
        except (ValueError, OSError, subprocess.SubprocessError):
            pass
        print(json.dumps({"installed": ready, "scope": "github-source", "runtime_ready": False}))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool=spec["name"]):
        print("Quelle:", spec["url"], "Pin:", spec["pin"])
        if opts.action == "uninstall":
            if marker.exists():
                if json.loads(marker.read_text(encoding="utf-8")) != record:
                    raise ValueError("Fremder Marker; nichts deaktiviert.")
                marker.unlink()
            print("Setupregistrierung deaktiviert; Quellen, Logs, Laufzeitpakete und Modelle bleiben erhalten.")
            return 0
        resources(base, base)
        if shutil.disk_usage(base).free < 1024**3:
            raise ValueError("Speicherplatzmangel: mindestens 1 GiB Disk-Reserve fuer Quellcheckout.")
        fetch(base, source, spec)
        if marker.exists():
            if json.loads(marker.read_text(encoding="utf-8")) != record:
                raise ValueError("Unbekannter Marker; erst manuell pruefen.")
            print("Gepinnter Quellstand bereits vorbereitet; kein Upgrade.")
            return 0
        fd, pending = tempfile.mkstemp(prefix="status-", dir=base)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as stream:
                json.dump(record, stream)
            os.replace(pending, marker)
        finally:
            if Path(pending).exists():
                Path(pending).unlink()
        print("GitHub-Quellen vorbereitet. Keine importierbare Runtime installiert oder getestet.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as exc:
        print("Offload-Quellinstaller:", exc, file=sys.stderr)
        sys.exit(1)
