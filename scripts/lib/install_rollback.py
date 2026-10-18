"""Rollback only explicitly enrolled, newly owned private tool roots on disk failure."""
import errno
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import uuid

ROOT = Path(__file__).resolve().parents[2]
OWNER = ".openclaw-install-owner"
DISK_ERROR = re.compile(r"no space left on device|\bENOSPC\b|disk quota exceeded|zu wenig freier (?:windows-host-)?speicher|fehler:[^\n]*windows-c:-reserve", re.I)


def safe(path):
    if not path.is_absolute() or ".." in path.parts:
        raise ValueError("Nicht normalisierter Installationspfad")
    for parent in (path, *path.parents):
        if parent.is_symlink() or (hasattr(parent, "is_junction") and parent.is_junction()):
            raise ValueError("Symlink/Junction: kein automatischer Rollback")
    if path.resolve() == ROOT or ROOT in path.resolve().parents:
        raise ValueError("Repo-interner User-Workspace ist nicht erlaubt")
    return path


def stream(command):
    tail = ""
    disk_failure = False
    with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) as proc:
        while True:
            chunk = os.read(proc.stdout.fileno(), 8192)
            if not chunk:
                break
            text = chunk.decode("utf-8", errors="replace")
            tail = (tail + text)[-32768:]
            disk_failure = disk_failure or bool(DISK_ERROR.search(tail))
            try:
                sys.stdout.buffer.write(chunk)
                sys.stdout.buffer.flush()
            except (OSError, BrokenPipeError):
                # A failed display/logger is not proof that the installation failed.
                pass
        return proc.wait(), disk_failure


def protected_tree(path):
    device = path.stat().st_dev
    for current, dirs, files in os.walk(path, followlinks=False):
        current = Path(current)
        if current.stat().st_dev != device or current.is_mount():
            return True
        for name in dirs + files:
            item = current / name
            if hasattr(item, "is_junction") and item.is_junction():
                return True
            if item.is_symlink():
                # rmtree unlinks symlinks, never recursively follows their targets.
                continue
            if item.stat().st_dev != device or item.is_mount():
                return True
            if name.lower() in {".env", ".ssh", "wallet", "wallets", "user_data", "userdata", "datasets", "private_keys", "models", "checkpoints"}:
                return True
    return False


def cleanup(target, record):
    safe(target)
    expected = safe(Path(record["root"]) / "tools" / record["directory"])
    if target != expected or target.resolve() != expected or str(target) != record["target"]:
        return "preserved-target-mismatch"
    if not target.exists():
        return "already-absent"
    marker = safe(target / OWNER)
    stat = target.stat()
    if (not target.is_dir() or not marker.is_file() or marker.read_text() != record["token"]
            or [stat.st_dev, stat.st_ino] != record["identity"]):
        return "preserved-ownership-mismatch"
    if protected_tree(target):
        return "preserved-protected-content"
    # No sudo, no external uninstallers, no shared caches or existing parent roots.
    shutil.rmtree(target)
    return "removed-new-root"


def run(tool, script, args=()):
    entries = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
    item = next((t for t in entries if t["name"] == tool), None)
    script = Path(script).resolve()
    if ROOT / "scripts/tools" not in script.parents or not script.name.endswith("_install.sh") or not script.is_file():
        raise ValueError("Nur vorhandene Tool-Installationsskripte erlaubt")
    command = ["bash", str(script), *args]
    policy = item.get("disk_rollback", {}) if item else {}
    if (not item or script != (ROOT / item["install_script"]).resolve()
            or policy.get("mode") != "new-private-root" or os.environ.get("INSTALL_DISK_ROLLBACK", "1") != "1"):
        rc, disk_failure = stream(command)
        if rc != 0 and disk_failure:
            print("Rollback nicht automatisch moeglich: kein freigegebener neuer privater Tool-Workspace. Keine bestehenden Daten geloescht.", flush=True)
        return rc
    name = policy["directory"]
    if not re.fullmatch(r"[a-z][a-z0-9_]{0,79}", name):
        raise ValueError("Ungueltige Rollback-Registry")
    root = safe(Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data"))))
    if root == Path(root.anchor):
        raise ValueError("User-Workspace darf keine Dateisystemwurzel sein")
    target = safe(root / "tools" / name)
    if target.exists():
        print("Rollback: vorhandenes Tool-Verzeichnis bleibt bei jedem Fehler erhalten.", flush=True)
        return stream(command)[0]
    transactions = safe(root / "install_transactions")
    transactions.mkdir(parents=True, exist_ok=True, mode=0o700)
    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    token = uuid.uuid4().hex
    journal = safe(transactions / (token + ".json"))
    record = {"tool": tool, "root": str(root), "directory": name, "target": str(target), "token": token, "state": "preparing"}
    # If another installer created it in the meantime, do not take ownership.
    try:
        target.mkdir(mode=0o700)
    except FileExistsError:
        return stream(command)[0]
    stat = target.stat()
    record["identity"] = [stat.st_dev, stat.st_ino]
    marker = safe(target / OWNER)
    try:
        marker.write_text(token, encoding="ascii")
        marker.chmod(0o600)
        with journal.open("x", encoding="utf-8") as out:
            json.dump(record, out)
        journal.chmod(0o600)
    except OSError:
        # No installer has run: only remove our marker and the still-empty directory.
        if marker.is_file() and marker.read_text() == token:
            marker.unlink()
        try:
            target.rmdir()
        except OSError:
            pass
        raise
    print("Rollback: neuer privater Tool-Workspace fuer diesen Versuch registriert.", flush=True)
    try:
        rc, disk_failure = stream(command)
    except OSError as exc:
        rc, disk_failure = 1, exc.errno in (errno.ENOSPC, errno.EDQUOT)
    if rc != 0 and disk_failure:
        try:
            record["state"] = cleanup(target, record)
        except (OSError, ValueError):
            record["state"] = "cleanup-incomplete-manual-inspection-required"
        print("Speicherplatz-Rollback: " + record["state"] + "; bestehende Installationen und externe Daten bleiben erhalten.", flush=True)
    else:
        record["state"] = "success-preserved" if rc == 0 else "non-disk-failure-preserved"
    try:
        if target.exists() and marker.is_file() and marker.read_text() == token:
            marker.unlink()
    except OSError:
        print("Eigentumsmarker konnte nicht entfernt werden; manuelle Pruefung erforderlich.", file=sys.stderr)
    try:
        journal.write_text(json.dumps(record) + "\n", encoding="utf-8")
    except OSError:
        print("Rollback-Journal konnte nicht aktualisiert werden; Ergebnis oben beachten.", file=sys.stderr)
    return rc


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if len(argv) < 2:
        print("Aufruf: install_rollback.py TOOL INSTALL_SCRIPT [ARGS...]", file=sys.stderr)
        return 2
    try:
        # Serialize menu-driven transactions, including retries of an existing root.
        root = safe(Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data"))))
        if root == Path(root.anchor):
            raise ValueError("User-Workspace darf keine Dateisystemwurzel sein")
        parent = safe(root / "install_transactions")
        parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        lock = safe(parent / ".runner-lock")
        try:
            lock.mkdir(mode=0o700)
        except FileExistsError:
            raise ValueError("Andere Installation aktiv oder Abbruch-Sperre vorhanden; zuerst pruefen")
        try:
            return run(argv[0], argv[1], argv[2:])
        finally:
            lock.rmdir()
    except (OSError, ValueError, KeyError) as exc:
        print("Rollback-Schutz: " + str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
