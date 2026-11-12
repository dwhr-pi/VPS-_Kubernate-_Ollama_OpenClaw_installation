"""Explicit, fingerprint-checked public-key import without overwriting files."""
import argparse
import base64
import hashlib
import os
from pathlib import Path
import re
import stat
import sys


def regular_read(path):
    if not stat.S_ISREG(path.lstat().st_mode):
        raise ValueError("Keine regulaere Datei")
    flags = os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0) | getattr(os, "O_BINARY", 0)
    fd = os.open(path, flags)
    with os.fdopen(fd, "rb") as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
            raise ValueError("Keine regulaere Datei")
        data = stream.read(8193)
    if len(data) > 8192:
        raise ValueError("Datei zu gross")
    return data


def checked_path(path):
    if not path.is_absolute() or ".." in path.parts:
        raise ValueError("Absoluten Pfad ohne .. verwenden")
    if any(p.is_symlink() or (hasattr(p, "is_junction") and p.is_junction()) for p in [path, *path.parents]):
        raise ValueError("Symlinks/Junctions nicht erlaubt")
    return path


def import_key(source, destination, expected):
    checked_path(source)
    checked_path(destination)
    if source.suffix != ".pub" or destination.name != "release.pub":
        raise ValueError("Nur oeffentliche .pub-Datei nach release.pub importieren; niemals release.key")
    if not re.fullmatch(r"[0-9a-fA-F]{64}", expected):
        raise ValueError("Unabhaengig bestaetigten SHA256 mit 64 Hex-Zeichen eingeben")
    data = regular_read(source)
    if hashlib.sha256(data).hexdigest() != expected.lower():
        raise ValueError("SHA256 stimmt nicht; nichts importiert")
    lines = data.decode("ascii").splitlines()
    if len(lines) == 2 and lines[0].startswith("untrusted comment: "):
        lines = lines[1:]
    if len(lines) != 1:
        raise ValueError("Kein Minisign-Public-Key-Format")
    decoded = base64.b64decode(lines[0], validate=True)
    if len(decoded) != 42 or decoded[:2] != b"Ed":
        raise ValueError("Kein Minisign-Public-Key")
    repo = Path(__file__).resolve().parents[2]
    if destination.resolve().is_relative_to(repo):
        raise ValueError("Trust-Ordner ausserhalb des Repos verwenden")
    destination.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    checked_path(destination)
    if destination.exists():
        if regular_read(destination) != data:
            raise ValueError("Ziel enthaelt anderen Schluessel; nichts ueberschrieben")
        return "Bereits bytegleich vorhanden; keine Aenderung."
    fd = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_NOFOLLOW", 0) | getattr(os, "O_BINARY", 0), 0o600)
    with os.fdopen(fd, "wb") as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())
    if regular_read(destination) != data:
        raise ValueError("Kopie nicht bytegleich; manuell pruefen, Quelle erhalten")
    return "Public Key bytegleich importiert. Quelle erhalten; kein Installer gestartet."


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path)
    parser.add_argument("--destination", type=Path, default=Path.home() / ".config/openclaw-trust/release.pub")
    parser.add_argument("--expected-sha256")
    parser.add_argument("--interactive", action="store_true")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args(argv)
    if not args.apply:
        print("Vorschau: --apply liest/importiert ausschliesslich den Public Key. Keine Dateien gelesen oder veraendert.")
        return 0
    if args.interactive:
        args.source = Path(input("Genauer absoluter Pfad zur release.pub (WSL: /mnt/c/...): ").strip().strip('"'))
        args.expected_sha256 = input("Unabhaengig bestaetigter SHA256: ").strip()
    if args.source is None or not args.expected_sha256:
        parser.error("--source und --expected-sha256 fehlen")
    print(import_key(args.source, args.destination, args.expected_sha256))
    print("Trust-Pfad:", args.destination)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, UnicodeError, EOFError) as error:
        print(f"Abgebrochen: {error}", file=sys.stderr)
        sys.exit(2)
