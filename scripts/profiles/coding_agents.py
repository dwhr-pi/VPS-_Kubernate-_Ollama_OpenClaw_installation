"""Profile templates and pinned source preparation, never an agent executor."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / "config/agents/coding_agents.json"


def catalog():
    return json.loads(CONFIG.read_text(encoding="utf-8"))


def private_root():
    raw = os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data"))
    path = Path(raw)
    if not path.is_absolute() or ".." in path.parts or path == Path(path.anchor):
        raise ValueError("User-Datenpfad muss absolut und normalisiert sein, nicht Dateisystemwurzel.")
    if path.resolve() == ROOT or ROOT in path.resolve().parents:
        raise ValueError("User-Daten muessen ausserhalb des Setup-Repos liegen.")
    safe(path)
    return path


def safe(path):
    for part in [path, *path.parents]:
        if part.is_symlink() or (hasattr(part, "is_junction") and part.is_junction()):
            raise ValueError("Symlink/Junction im Zielpfad; keine Aenderung.")
    return path


@contextmanager
def operation(base):
    safe(base).mkdir(parents=True, exist_ok=True, mode=0o700)
    lock = safe(base / ".operation-lock")
    try:
        lock.mkdir(mode=0o700)
    except FileExistsError:
        raise ValueError("Operation aktiv oder Sperre nach Abbruch vorhanden; zuerst manuell pruefen.")
    try:
        yield
    finally:
        lock.rmdir()


def write_new_or_same(path, data):
    safe(path)
    if path.exists():
        if path.read_bytes() != data:
            raise ValueError("Vorhandene Datei weicht ab; erst sichern/pruefen: " + path.name)
        return
    with path.open("xb") as stream:
        stream.write(data)
    path.chmod(0o600)


def encoded(value):
    return (json.dumps(value, indent=2, ensure_ascii=True) + "\n").encode()


def profile_action(profile_id, action):
    item = next((p for p in catalog()["profiles"] if p["id"] == profile_id), None)
    if item is None:
        raise ValueError("Unbekanntes Profil")
    root = private_root()
    base = safe(root / "agent_profiles" / profile_id)
    target = safe(base / "profile.json")
    marker = safe(base / "installed.json")
    payload = encoded(item)
    record = {"profile": profile_id, "scope": "profile-template", "sha256": hashlib.sha256(payload).hexdigest(), "runtime_ready": False}
    ready = target.is_file() and marker.is_file() and target.read_bytes() == payload and marker.read_bytes() == encoded(record)
    if action in ("--dry-run", "--plan", "plan"):
        print(json.dumps({"profile": profile_id, "action": "copy-template-only", "target": str(target), "runtime_ready": False}))
        return 0
    if action in ("status", "check", "doctor", "--check"):
        print(json.dumps({"profile": profile_id, "template_installed": ready, "runtime_ready": False}))
        return 0 if ready or action == "status" else 1
    if action not in ("install", "update", "--repair", "uninstall", "--uninstall"):
        raise ValueError("Keine Agentenausfuehrung; nur Profilvorlagen verwalten.")
    if action in ("uninstall", "--uninstall") and not base.exists():
        return 0
    with operation(base):
        if action in ("uninstall", "--uninstall"):
            if marker.exists():
                if marker.read_bytes() != encoded(record):
                    raise ValueError("Fremder/geaenderter Marker; nichts entfernt.")
                marker.unlink()
            print("Nur Profilregistrierung deaktiviert; Vorlagen, CLIs und Nutzdaten bleiben erhalten.")
        else:
            if shutil.disk_usage(base).free < 16 * 1024**2:
                raise ValueError("Mindestens 16 MiB freie Disk fuer Vorlagen erforderlich.")
            write_new_or_same(target, payload)
            write_new_or_same(marker, encoded(record))
            print(profile_id + ": Profilvorlage installiert; keine Tools, Modelle, Dienste oder Agenten gestartet.")
    return 0


def git(source, *args):
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0", GIT_LFS_SKIP_SMUDGE="1")
    return subprocess.run(["git", "-c", "credential.helper=", "-c", "core.hooksPath=" + os.devnull,
                           "-C", str(source), *args], env=env, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True).stdout.strip()


def source_ok(source, item):
    try:
        safe(source / ".git")
        return ((source / ".git").is_dir() and Path(git(source, "rev-parse", "--show-toplevel")).resolve() == source.resolve()
                and git(source, "remote", "get-url", "origin") == item["github"]
                and git(source, "rev-parse", "HEAD") == item["commit"]
                and not git(source, "status", "--porcelain", "--untracked-files=all"))
    except (OSError, ValueError, subprocess.CalledProcessError):
        return False


def source_action(provider, action):
    item = catalog()["providers"][provider]
    base = safe(private_root() / "tools" / provider)
    source = safe(base / "source")
    marker = safe(base / "source-ready.json")
    record = encoded({"commit": item["commit"], "scope": item["scope"], "runtime_ready": False})
    if action in ("--dry-run", "--plan", "plan"):
        print(json.dumps(dict(item, runtime_ready=False)))
        return 0
    if action in ("status", "check", "doctor", "--check"):
        ready = marker.is_file() and marker.read_bytes() == record and source_ok(source, item)
        print(json.dumps({"source_ready": ready, "runtime_ready": False, "scope": item["scope"]}))
        return 0 if ready or action == "status" else 1
    if action not in ("install", "update", "--repair", "uninstall", "--uninstall"):
        raise ValueError("Kein CLI-/Cloud-/Loginstart implementiert.")
    if action in ("uninstall", "--uninstall") and not base.exists():
        return 0
    with operation(base):
        if action in ("uninstall", "--uninstall"):
            if marker.exists():
                if marker.read_bytes() != record:
                    raise ValueError("Fremder Marker; nichts geloescht.")
                marker.unlink()
            print("Quellregistrierung deaktiviert; Quellen und Nutzdaten erhalten.")
            return 0
        if shutil.disk_usage(base).free < 2 * 1024**3:
            raise ValueError("GitHub-Quellen: mindestens 2 GiB freie Ziel-Disk erforderlich.")
        if source.exists():
            if not source_ok(source, item):
                raise ValueError("Fremde/geaenderte/unvollstaendige Quelle; kein Reset oder Loeschen.")
        else:
            source.mkdir(mode=0o700)
            git(source, "init", "--initial-branch=main")
            git(source, "remote", "add", "origin", item["github"])
            git(source, "fetch", "--depth", "1", "origin", item["commit"])
            git(source, "checkout", "--detach", "FETCH_HEAD")
        if not source_ok(source, item):
            raise ValueError("Quell-Pin-/Originpruefung fehlgeschlagen.")
        write_new_or_same(marker, record)
        print(provider + ": GitHub-Quellen vorbereitet, keine CLI gebaut/installiert oder gestartet. " + item["scope"])
    return 0


def route(task, allow_cloud=False):
    config = catalog()
    preferred = config["routes"][task]
    item = next(p for p in config["profiles"] if p["id"] == preferred)
    selected = preferred if allow_cloud or not item["cloud"] else "Ollama_Coder"
    return {"task": task, "preferred_profile": preferred, "selected_profile": selected,
            "cloud_allowed": allow_cloud, "scope": "offline-routing-plan", "executed": False,
            "reason": "cloud-disabled-local-fallback" if selected != preferred else "role-match"}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=("profile", "source", "route"))
    parser.add_argument("name")
    parser.add_argument("action", nargs="?", default="--dry-run")
    parser.add_argument("--dry-run", dest="dry_run", action="store_true")
    for flag in ("--repair", "--check", "--uninstall", "--plan", "--status"):
        parser.add_argument(flag, dest="override_action", action="store_const", const=flag)
    parser.add_argument("--allow-cloud", action="store_true", help="Nur Routingplan, kein Cloud-Aufruf")
    args = parser.parse_args(argv)
    try:
        if args.kind == "route":
            print(json.dumps(route(args.name, args.allow_cloud)))
            return 0
        action = "--dry-run" if args.dry_run else (args.override_action or args.action)
        if action == "--status":
            action = "status"
        return profile_action(args.name, action) if args.kind == "profile" else source_action(args.name, action)
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError) as exc:
        # Git stderr is deliberately not echoed: credentials/proxy URLs may be present.
        print("Fehler: " + ("GitHub-Operation fehlgeschlagen; Quelle erhalten." if isinstance(exc, subprocess.CalledProcessError) else str(exc)), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
