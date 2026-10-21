"""Pinned official Go archive bootstrap inside a tool workspace, without sudo."""
import hashlib
import errno
import json
import os
from pathlib import Path, PurePosixPath
import platform
import re
import shutil
import stat
import tarfile
import tempfile
import time
from urllib.error import URLError
from urllib.request import HTTPRedirectHandler, ProxyHandler, Request, build_opener
import zipfile

from find_skills import checked

VERSION = "go1.27.3"
# Official https://go.dev/dl/?mode=json metadata, checked 2026-10-21.
ARCHIVES = {
    "linux-amd64": ("65efbc80fdc1fa2cd2631cad5b481777a68e8725f34e89f50fc6ac714e379b40", 70588678),
    "linux-arm64": ("a06e99309dbcbdca1a8ccd2282c3ee146e55930886e26b4f1193269587165f49", 67076044),
    "darwin-amd64": ("b6f8e931e4ab497fcde6da8ae4499a58f9d258e55c8a80824a516eae5950a750", 71697771),
    "darwin-arm64": ("dd3908cf20959d798c1e06ebe5b72213f0505ce01373b40ce3110975a6cd99c2", 68196737),
    "windows-amd64": ("f26081f438319757f8a1b46d7d0b2c5ec7583d4038e485e0aa725cfde7885fff", 79010309),
    "windows-arm64": ("c507872ff21f8a7cd3c1c217b059c6f7271a4a9d8e692810ef9dd3e1f601197c", 75113075),
}
MAX_UNPACKED = 1024**3
MAX_FILES = 60000


def target():
    system = platform.system().lower()
    machine = platform.machine().lower()
    arch = {"x86_64": "amd64", "amd64": "amd64", "aarch64": "arm64", "arm64": "arm64"}.get(machine)
    key = system + "-" + (arch or "unsupported")
    if key not in ARCHIVES:
        raise ValueError("Privater Go-Bootstrap unterstuetzt nur Linux/macOS/Windows mit amd64/arm64; Go separat bereitstellen.")
    suffix = ".zip" if system == "windows" else ".tar.gz"
    filename = VERSION + "." + key + suffix
    return key, filename, ARCHIVES[key]


def digest(path):
    checksum = hashlib.sha256()
    with checked(path).open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024**2), b""):
            checksum.update(chunk)
    return checksum.hexdigest()


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def download(filename, destination, expected_hash, expected_size):
    url = "https://dl.google.com/go/" + filename
    print("Go-Download:", url, "Bytes:", expected_size, "SHA256:", expected_hash)
    # Do not inherit proxy credentials or send keys; no redirects or retries.
    opener = build_opener(ProxyHandler({}), NoRedirect())
    checksum, total, started = hashlib.sha256(), 0, time.monotonic()
    try:
        with opener.open(Request(url, headers={"User-Agent": "OpenClaw-Setup-Go-Bootstrap"}), timeout=60) as response:
            if response.status != 200 or response.geturl() != url:
                raise ValueError("Unerwartete Go-Downloadantwort.")
            with checked(destination).open("xb") as output:
                while True:
                    if time.monotonic() - started > 600:
                        raise ValueError("Go-Download-Zeitlimit erreicht.")
                    chunk = response.read(1024**2)
                    if not chunk:
                        break
                    total += len(chunk)
                    if total > expected_size:
                        raise ValueError("Go-Archiv groesser als gepruefte Metadaten.")
                    checksum.update(chunk)
                    output.write(chunk)
    except (OSError, URLError) as error:
        if getattr(error, "errno", None) in (errno.ENOSPC, errno.EDQUOT):
            raise ValueError("Speicherplatzmangel beim Go-Download; Staging wird entfernt, keine Toolchain aktiviert.") from None
        raise ValueError("Offizieller Go-Download fehlgeschlagen; keine Systemaenderung. Netzwerk/Proxy/Schreibrechte pruefen oder Go separat bereitstellen.") from None
    if total != expected_size or checksum.hexdigest() != expected_hash:
        raise ValueError("Go-Archiv-Pruefsumme/Groesse stimmt nicht; kein Entpacken oder Ausfuehren.")


def relative(name):
    path = PurePosixPath(name)
    if (not name or any(char in name for char in ("\\", ":", "\0")) or path.is_absolute() or
            not path.parts or path.parts[0] != "go" or ".." in path.parts):
        raise ValueError("Unsicherer Pfad im Go-Archiv.")
    return path


def extract(archive, destination):
    """Copy regular files explicitly; never extract links, devices or paths outside go/."""
    seen, total, count = set(), 0, 0

    def copy(name, size, mode, directory, open_member):
        nonlocal total, count
        name = relative(name).as_posix()
        count += 1
        if name in seen or count > MAX_FILES or size < 0 or size > MAX_UNPACKED:
            raise ValueError("Unerwartete Groesse/Dateiliste im Go-Archiv.")
        seen.add(name)
        path = checked(destination / name)
        if directory:
            path.mkdir(mode=0o700, parents=True, exist_ok=True)
            return
        if name == "go":
            raise ValueError("Go-Archivwurzel muss ein Verzeichnis sein.")
        total += size
        if total > MAX_UNPACKED:
            raise ValueError("Entpacktes Go-Archiv ueberschreitet 1 GiB.")
        path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        with open_member() as source, path.open("xb") as output:
            remaining = size
            while remaining:
                chunk = source.read(min(1024**2, remaining))
                if not chunk:
                    raise ValueError("Unvollstaendige Go-Archivdatei.")
                output.write(chunk)
                remaining -= len(chunk)
            if source.read(1):
                raise ValueError("Go-Archivdatei groesser als angegeben.")
        path.chmod(0o700 if mode & 0o111 else 0o600)

    try:
        if archive.suffix == ".zip":
            with zipfile.ZipFile(archive) as bundle:
                for member in bundle.infolist():
                    mode = member.external_attr >> 16
                    if stat.S_IFMT(mode) not in (0, stat.S_IFREG, stat.S_IFDIR):
                        raise ValueError("Links/Spezialdateien im Go-ZIP nicht erlaubt.")
                    copy(member.filename, member.file_size, mode, member.is_dir(), lambda m=member: bundle.open(m))
        else:
            with tarfile.open(archive, "r:gz") as bundle:
                for member in bundle:
                    if not (member.isdir() or member.isfile()):
                        raise ValueError("Links/Spezialdateien im Go-TAR nicht erlaubt.")
                    copy(member.name, member.size, member.mode, member.isdir(), lambda m=member: bundle.extractfile(m))
    except (tarfile.TarError, zipfile.BadZipFile):
        raise ValueError("Ungueltiges Go-Archiv; keine Toolchain aktiviert.") from None


def inventory(root):
    hashes = {}
    for path in sorted(root.rglob("*")):
        checked(path)
        if path.is_dir():
            continue
        if not path.is_file():
            raise ValueError("Unbekannte Datei in privater Go-Toolchain.")
        hashes[path.relative_to(root).as_posix()] = digest(path)
    return hashes


def verify_private(slot, key, archive_hash):
    checked(slot)
    marker = checked(slot / "toolchain-ready.json")
    data = json.loads(marker.read_text(encoding="utf-8"))
    if (not isinstance(data, dict) or data.get("version") != VERSION or data.get("platform") != key or
            data.get("archive_sha256") != archive_hash or not isinstance(data.get("hashes"), dict) or
            not data["hashes"] or len(data["hashes"]) > MAX_FILES):
        raise ValueError("Unbekannte private Go-Toolchain; keine Dateien ersetzen.")
    for name, checksum in data["hashes"].items():
        relative("go/" + name)
        if not re.fullmatch(r"[a-f0-9]{64}", str(checksum)):
            raise ValueError("Ungueltiger Go-Besitznachweis.")
    root = checked(slot / "go")
    if inventory(root) != data["hashes"]:
        raise ValueError("Private Go-Toolchain lokal veraendert/unvollstaendig; nichts ueberschreiben.")
    binary = checked(root / "bin" / ("go.exe" if key.startswith("windows-") else "go"))
    if not binary.is_file() or binary.stat().st_size == 0:
        raise ValueError("Privates Go-Binary fehlt.")
    if not (root / "VERSION").read_text(encoding="utf-8").startswith(VERSION + "\n"):
        raise ValueError("Unerwartete private Go-Version.")
    return binary, root


def ensure(base, validate):
    """Caller owns the workspace operation lock and resource preflight."""
    key, filename, (archive_hash, archive_size) = target()
    parent = checked(base / "toolchain")
    slot = checked(parent / (VERSION + "-" + key))
    if slot.exists():
        binary, root = verify_private(slot, key, archive_hash)
        validate(binary, root, key)
        print("Bereits gepruefte private Go-Toolchain wiederverwendet:", root)
        return str(binary), root
    if shutil.disk_usage(base).free < 4 * 1024**3:
        raise ValueError("Speicherplatzmangel vor Go-Bootstrap: mindestens 4 GiB freie Ziel-Disk erforderlich.")
    print("Stelle isoliertes", VERSION, "bereit; System-Go und PATH bleiben unveraendert.")
    with tempfile.TemporaryDirectory(prefix="go-bootstrap-", dir=base) as staging:
        stage = checked(Path(staging))
        archive = checked(stage / filename)
        download(filename, archive, archive_hash, archive_size)
        payload = checked(stage / "payload")
        payload.mkdir(mode=0o700)
        extract(archive, payload)
        root = checked(payload / "go")
        binary = checked(root / "bin" / ("go.exe" if key.startswith("windows-") else "go"))
        if not binary.is_file() or binary.stat().st_size == 0:
            raise ValueError("Go-Archiv enthaelt kein nutzbares Go-Binary.")
        if not (root / "VERSION").read_text(encoding="utf-8").startswith(VERSION + "\n"):
            raise ValueError("Go-Archiv-Version stimmt nicht mit Pin ueberein.")
        validate(binary, root, key)
        data = {"version": VERSION, "platform": key, "archive_sha256": archive_hash, "hashes": inventory(root)}
        with (payload / "toolchain-ready.json").open("x", encoding="utf-8") as output:
            json.dump(data, output)
        (payload / "toolchain-ready.json").chmod(0o600)
        parent.mkdir(mode=0o700, exist_ok=True)
        if slot.exists():
            raise ValueError("Privates Go-Ziel zwischenzeitlich belegt; nichts ersetzen.")
        payload.rename(slot)
    print("Private Go-Toolchain geprueft:", slot / "go")
    root = checked(slot / "go")
    return str(root / "bin" / binary.name), root
