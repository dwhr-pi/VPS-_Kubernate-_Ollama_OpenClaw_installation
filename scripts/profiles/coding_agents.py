"""Profile templates and pinned source preparation, never an agent executor."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
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
    metadata(path, directory=True)
    return path


def safe(path):
    for part in [path, *path.parents]:
        if part.is_symlink() or (hasattr(part, "is_junction") and part.is_junction()):
            raise ValueError("Symlink/Junction im Zielpfad; keine Aenderung.")
    return path


def metadata(path, *, directory=False):
    safe(path)
    try:
        info = path.lstat()
    except FileNotFoundError:
        return None
    valid_type = stat.S_ISDIR(info.st_mode) if directory else stat.S_ISREG(info.st_mode)
    if not valid_type or (not directory and info.st_nlink != 1):
        raise ValueError('Private regular file/directory required; no hardlink adoption.')
    # Windows ACLs are a separate acceptance gate, never inferred from POSIX mode bits.
    if os.name == 'posix' and (info.st_uid != os.getuid() or
                               stat.S_IMODE(info.st_mode) != (0o700 if directory else 0o600)):
        raise ValueError('Private owner and 0700 directory/0600 file required; existing data preserved.')
    return info


def read_owned(path):
    before = metadata(path)
    if before is None:
        return None
    flags = os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0) | getattr(os, 'O_NONBLOCK', 0)
    with os.fdopen(os.open(path, flags), 'rb') as stream:
        after = os.fstat(stream.fileno())
        if ((before.st_dev, before.st_ino) != (after.st_dev, after.st_ino)
                or not stat.S_ISREG(after.st_mode) or after.st_nlink != 1 or after.st_size > 1024**2):
            raise ValueError('Private file changed or oversized; no adoption.')
        result = stream.read(1024**2 + 1)
        if len(result) > 1024**2:
            raise ValueError('Private file too large.')
        return result


@contextmanager
def operation(base):
    root = private_root()
    if not base.is_relative_to(root):
        raise ValueError('Operation outside private workspace refused.')
    # Create each managed level privately; do not chmod/adopt pre-existing directories.
    current = root
    for part in (None, *base.relative_to(root).parts):
        if part is not None:
            current = current / part
        if metadata(current, directory=True) is None:
            current.mkdir(mode=0o700)
        metadata(current, directory=True)
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
    metadata(path.parent, directory=True)
    previous = read_owned(path)
    if previous is not None:
        if previous != data:
            raise ValueError("Vorhandene Datei weicht ab; erst sichern/pruefen: " + path.name)
        return
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, 'O_NOFOLLOW', 0)
    with os.fdopen(os.open(path, flags, 0o600), 'wb') as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())


def encoded(value):
    return (json.dumps(value, indent=2, ensure_ascii=True) + "\n").encode()


def profile_action(profile_id, action, profile_catalog=None):
    item = next((p for p in (profile_catalog or catalog())["profiles"] if p["id"] == profile_id), None)
    if item is None:
        raise ValueError("Unbekanntes Profil")
    root = private_root()
    base = safe(root / "agent_profiles" / profile_id)
    target = safe(base / "profile.json")
    marker = safe(base / "installed.json")
    payload = encoded(item)
    record = {"profile": profile_id, "scope": "profile-template", "sha256": hashlib.sha256(payload).hexdigest(), "runtime_ready": False}
    if action in ("--dry-run", "--plan", "plan"):
        print(json.dumps({"profile": profile_id, "action": "copy-template-only", "target": str(target), "runtime_ready": False}))
        return 0
    for directory in (root / 'agent_profiles', base):
        metadata(directory, directory=True)
    ready = read_owned(target) == payload and read_owned(marker) == encoded(record)
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
                if read_owned(marker) != encoded(record):
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
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=120).stdout.strip()


def source_ok(source, item):
    try:
        safe(source / ".git")
        return ((source / ".git").is_dir() and Path(git(source, "rev-parse", "--show-toplevel")).resolve() == source.resolve()
                and git(source, "remote", "get-url", "origin") == item["github"]
                and git(source, "rev-parse", "HEAD") == item["commit"]
                and not git(source, "status", "--porcelain", "--untracked-files=all"))
    except (OSError, ValueError, subprocess.SubprocessError):
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
        for directory in (base.parent, base):
            metadata(directory, directory=True)
        ready = read_owned(marker) == record and source_ok(source, item)
        print(json.dumps({"source_ready": ready, "runtime_ready": False, "scope": item["scope"]}))
        return 0 if ready or action == "status" else 1
    if action not in ("install", "update", "--repair", "uninstall", "--uninstall"):
        raise ValueError("Kein CLI-/Cloud-/Loginstart implementiert.")
    if action in ("uninstall", "--uninstall") and not base.exists():
        return 0
    with operation(base):
        if action in ("uninstall", "--uninstall"):
            if marker.exists():
                if read_owned(marker) != record:
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
    parser.add_argument("kind", choices=("profile", "local-profile", "source", "route"))
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
        if args.kind == 'local-profile':
            local = json.loads((ROOT / 'config/agents/local_profiles.json').read_text(encoding='utf-8'))
            return profile_action(args.name, action, local)
        return profile_action(args.name, action) if args.kind == "profile" else source_action(args.name, action)
    except (ValueError, KeyError, OSError, subprocess.SubprocessError) as exc:
        # Git stderr is deliberately not echoed: credentials/proxy URLs may be present.
        print("Fehler: " + ("GitHub-Operation fehlgeschlagen; Quelle erhalten." if isinstance(exc, subprocess.SubprocessError) else str(exc)), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
