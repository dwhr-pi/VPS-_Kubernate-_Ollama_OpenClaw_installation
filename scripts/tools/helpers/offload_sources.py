"""Optional pinned source checkouts; no dependencies, builds, drivers or models."""
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
    "agentic_os": {
        "name": "Agentic_OS", "url": "https://github.com/modimihir07/agentic-os.git",
        "pin": "9dfcc24b0c97dca4ce5cc567fc5d1ac198df3ab6",
        "module": "server.py",
        "files": ("LICENSE", "README.md", "server.py", "requirements.txt",
                  "dashboard/index.html", "scheduler/scheduler.py", "start.sh"),
        "plan_note": "Evaluationskandidat, nur Quellen. Kein Dashboard, Scheduler, Agent, Keyzugriff oder Bootstrap. 1 GiB Disk-Reserve.",
    },
    "colibri": {
        "name": "Colibri", "url": "https://github.com/JustVugg/colibri.git",
        "pin": "e0db083cdc9e563e0766cc6fc661ef23c32298e0",
        "module": "c/coli",
        "files": ("LICENSE", "README.md", "pyproject.toml", "c/Makefile", "c/coli"),
    },
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
    "hyperfine": {
        "name": "Hyperfine", "url": "https://github.com/sharkdp/hyperfine.git",
        "pin": "c5161524980522320c7d3425e714cc0965a869a5",
        "module": "src/main.rs",
        "files": ("LICENSE-MIT", "LICENSE-APACHE", "Cargo.toml", "Cargo.lock", "src/main.rs"),
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
    for name in spec.get("files", ("LICENSE", "setup.py", spec["module"])):
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
    parser.add_argument("--dry-run", action="store_true")
    modes = parser.add_mutually_exclusive_group()
    for mode in ("check", "repair", "uninstall", "status"):
        modes.add_argument("--" + mode, dest="override", action="store_const", const=mode)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen; keine Aenderung ausgefuehrt.")
        opts.action = opts.override
    if opts.dry_run:
        opts.action = "plan"
    spec = TOOLS[opts.tool]
    base, source, marker = paths(opts.tool)
    record = {"commit": spec["pin"], "scope": "github-source", "runtime_ready": False}
    if opts.action == "plan":
        print(spec["name"], spec["url"], spec["pin"], "Ziel:", source)
        print(spec.get("plan_note", "Nur Quellen: keine pip-/Torch-/CUDA-/ROCm-/Modellinstallation. 1 GiB Disk-Reserve."))
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
        print("GitHub-Quellen vorbereitet. Keine gebaute/installierte Runtime getestet.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as exc:
        print("Offload-Quellinstaller:", exc, file=sys.stderr)
        sys.exit(1)
