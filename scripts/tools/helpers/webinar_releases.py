"""Install pinned official GitHub releases, without Docker or service setup."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import platform
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
from urllib.parse import urlsplit
from urllib.request import HTTPRedirectHandler, build_opener
import zipfile

from find_skills import checked, operation


SPECS = {
    "marp": {
        "name": "Marp", "repo": "marp-team/marp-cli", "version": "4.5.1", "tag": "v4.5.1",
        "license": "MIT", "reserve_mb": 1024,
        "artifacts": {
            "windows-amd64": ("marp-cli-v4.5.1-win.zip", 47070928, "34f3eac66899c5d715bcd82248c6ceb063fa60c523931f15c4aa1e03e909cafa"),
            "linux-amd64": ("marp-cli-v4.5.1-linux.tar.gz", 49064724, "2fc36a8799450d28fe0c91194c1bc690d487051eae4b81b239b741a7a9a4b7da"),
            "linux-arm64": ("marp-cli-v4.5.1-linux-arm64.tar.gz", 48644453, "a360f1e37fce442ee7aa0d0e0a2f86cc239d9f431861c7f5469ccdc78ffe5fc7"),
        },
    },
    "listmonk": {
        "name": "Listmonk", "repo": "knadh/listmonk", "version": "6.2.0", "tag": "v6.2.0",
        "license": "AGPL-3.0", "reserve_mb": 1024,
        "artifacts": {
            "windows-amd64": ("listmonk_6.2.0_windows_amd64.tar.gz", 9870271, "4c05f28d267d4e9cfb85e1ab9ba32cde50954ac5715472721a5325cd0a39880e"),
            "windows-arm64": ("listmonk_6.2.0_windows_arm64.tar.gz", 9142837, "ccc163bb93277d4e0d589596757ea79f9676b4208efe14c45e0b8a143ffb0a3a"),
            "linux-amd64": ("listmonk_6.2.0_linux_amd64.tar.gz", 9664556, "ce78c89d8aac0df3ffe0e110b008e7bb5dae13e6ad0c57b43aa7094971e8698e"),
            "linux-arm64": ("listmonk_6.2.0_linux_arm64.tar.gz", 9043438, "7e8f77dcdd2caf83b4b7774ecc44de7cea6852596084a4a2b5aab15464a45549"),
        },
    },
    "mautic": {
        "name": "Mautic", "repo": "mautic/mautic", "version": "7.2.1", "tag": "7.2.1",
        "license": "GPL-3.0-or-later", "reserve_mb": 2048,
        "artifacts": {"any": ("7.2.1.zip", 105311972, "5c86cf1fe8b4f9818232ce8bb755760f502d47846706e9164d144865d031ecbd")},
    },
}


def host_key():
    system = {"Windows": "windows", "Linux": "linux"}.get(platform.system(), "unsupported")
    machine = {"AMD64": "amd64", "x86_64": "amd64", "aarch64": "arm64", "ARM64": "arm64"}.get(platform.machine(), "unsupported")
    return system + "-" + machine


def artifact(spec):
    value = spec["artifacts"].get(host_key(), spec["artifacts"].get("any"))
    if not value:
        raise ValueError("Fuer diese Plattform ist kein geprueftes Release hinterlegt.")
    name, size, digest = value
    return "https://github.com/" + spec["repo"] + "/releases/download/" + spec["tag"] + "/" + name, size, digest


class ReleaseRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        parts = urlsplit(newurl)
        if parts.scheme != "https" or parts.hostname not in ("github.com", "release-assets.githubusercontent.com", "objects.githubusercontent.com") or parts.username or parts.password:
            raise ValueError("Download-Redirect ausserhalb offizieller GitHub-Hosts blockiert.")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def download(url, target, size, expected):
    digest, total = hashlib.sha256(), 0
    with build_opener(ReleaseRedirect()).open(url, timeout=30) as response, target.open("xb") as stream:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            total += len(chunk)
            if total > size:
                raise ValueError("Release groesser als gepruefte Dateigroesse.")
            digest.update(chunk)
            stream.write(chunk)
    if total != size or digest.hexdigest() != expected:
        raise ValueError("Release-Groesse oder SHA256 stimmt nicht; nichts installiert.")


def entry_path(root, name):
    if not name or "\\" in name or ":" in name or "\x00" in name:
        raise ValueError("Unsicherer Archivpfad.")
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError("Archivpfad verlaesst Installationsordner.")
    return root.joinpath(*path.parts)


def unpack(archive, dest):
    # Never use extractall: reject links, special files, traversal and zip bombs.
    total, seen = 0, set()

    def put(name, size, source, is_dir=False, mode=0o644):
        nonlocal total
        target = entry_path(dest, name)
        key = str(target).casefold()
        if key in seen or len(seen) >= 60000:
            raise ValueError("Doppelter Archivpfad oder zu viele Dateien.")
        seen.add(key)
        total += size
        if size < 0 or total > 1024**3:
            raise ValueError("Entpacklimit von 1 GiB erreicht.")
        if is_dir:
            target.mkdir(parents=True, exist_ok=True)
            return
        target.parent.mkdir(parents=True, exist_ok=True)
        with source() as data, target.open("xb") as output:
            remaining = size
            while remaining:
                chunk = data.read(min(1024 * 1024, remaining))
                if not chunk:
                    raise ValueError("Unvollstaendige Archivdatei.")
                output.write(chunk)
                remaining -= len(chunk)
        target.chmod(0o755 if mode & 0o111 else 0o644)

    if zipfile.is_zipfile(archive):
        with zipfile.ZipFile(archive) as bundle:
            for item in bundle.infolist():
                mode = item.external_attr >> 16
                if stat.S_ISLNK(mode) or (stat.S_IFMT(mode) not in (0, stat.S_IFREG, stat.S_IFDIR)):
                    raise ValueError("Archiv enthaelt Links/Spezialdateien.")
                put(item.filename, item.file_size, lambda i=item: bundle.open(i), item.is_dir(), mode)
    else:
        with tarfile.open(archive, "r:gz") as bundle:
            for item in bundle:
                if not (item.isfile() or item.isdir()):
                    raise ValueError("Archiv enthaelt Links/Spezialdateien.")
                put(item.name, item.size, lambda i=item: bundle.extractfile(i), item.isdir(), item.mode)


def paths(key):
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluter externer User-Workspace erforderlich.")
    base = checked(raw / "tools" / key)
    return base, checked(base / "app"), checked(base / "release-ready.json")


def digest(path):
    with checked(path).open("rb") as source:
        value = hashlib.sha256()
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def inventory(app):
    return {p.relative_to(app).as_posix(): digest(p) for p in sorted(app.rglob("*")) if checked(p).is_file()}


def validate_record(app, marker, spec, full=False):
    data = json.loads(marker.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("version") != spec["version"] or data.get("repo") != spec["repo"] or not isinstance(data.get("hashes"), dict) or not data["hashes"]:
        raise ValueError("Unbekannter/unvollstaendiger Installationsnachweis.")
    entry = entry_path(app, data["entry"])
    if digest(entry) != data["hashes"].get(data["entry"]):
        raise ValueError("Programm fehlt oder ist veraendert.")
    if full and inventory(app) != data["hashes"]:
        raise ValueError("Lokale Aenderungen/Zusatzdateien: vor Reparatur/Entfernung sichern.")
    return data


def reserve(base, spec):
    required = spec["reserve_mb"] * 1024**2
    free = shutil.disk_usage(base).free
    print("Freier Zielspeicher MiB:", free // 1024**2, "Mindestreserve MiB:", spec["reserve_mb"])
    if free < required:
        raise ValueError("Speicherplatzmangel vor Download; keine Paketdateien installiert.")
    if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").exists():
        free = shutil.disk_usage("/mnt/c").free
        print("Freier Windows-C:-Speicher MiB:", free // 1024**2)
        if free < required:
            raise ValueError("Windows-Host-Speicherplatzmangel vor Download.")


def install(key, base, app, marker, spec):
    if marker.exists():
        validate_record(app, marker, spec, full=True)
        print("Geprueftes Release bereits installiert; kein latest-Upgrade.")
        return
    if app.exists():
        raise ValueError("Unverwaltetes app-Verzeichnis; kein Ueberschreiben oder Loeschen.")
    reserve(base, spec)
    url, size, expected = artifact(spec)
    stage = Path(tempfile.mkdtemp(prefix="release-stage-", dir=base))
    published = False
    try:
        print("GitHub-Release:", url, "SHA256:", expected)
        archive, unpacked = stage / "archive", stage / "app"
        unpacked.mkdir()
        download(url, archive, size, expected)
        unpack(archive, unpacked)
        if key == "mautic":
            entry = "bin/console"
            for required in (entry, "vendor/autoload.php", "composer.json", "index.php"):
                if not (unpacked / required).is_file():
                    raise ValueError("Mautic-Vollpaket unvollstaendig: " + required)
        else:
            name = ("marp" if key == "marp" else "listmonk") + (".exe" if platform.system() == "Windows" else "")
            matches = list(unpacked.rglob(name))
            if len(matches) != 1:
                raise ValueError("Release-Programmeinstieg nicht eindeutig.")
            binary = matches[0]
            binary.chmod(0o755)
            result = subprocess.run([str(binary), "--version"], capture_output=True, text=True, check=True, timeout=60)
            if spec["version"] not in result.stdout + result.stderr:
                raise ValueError("Programm meldet nicht die gepruefte Version.")
            print("Versionspruefung erfolgreich:", spec["version"])
            entry = binary.relative_to(unpacked).as_posix()
        record = {"repo": spec["repo"], "version": spec["version"], "artifact_sha256": expected,
                  "scope": "official-github-release", "entry": entry, "hashes": inventory(unpacked),
                  "runtime_ready": key == "marp", "service_configured": False}
        pending = stage / "release-ready.json"
        pending.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
        unpacked.rename(app)
        published = True
        pending.rename(marker)
        print(spec["name"], "Release installiert:", app)
        print("Kein PATH-Umbau, Docker, Webserver, Datenbank, SMTP oder Kampagnenstart.")
        if key != "marp":
            print("Anwendungsdateien installiert; DB/PHP/Web-/Mail-Konfiguration separat erforderlich.")
    except Exception:
        if published and not marker.exists():
            shutil.rmtree(checked(app))
        print("Rollback: nur neue Dateien dieses Versuchs entfernt; vorhandene Daten bleiben erhalten.")
        raise
    finally:
        if stage.exists():
            shutil.rmtree(checked(stage))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=SPECS)
    parser.add_argument("action", nargs="?", default="install", choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    overrides = parser.add_mutually_exclusive_group()
    for action in ("repair", "uninstall", "check", "status"):
        overrides.add_argument("--" + action, dest="override", action="store_const", const=action)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen; nichts ausgefuehrt.")
        opts.action = opts.override
    spec = SPECS[opts.tool]
    base, app, marker = paths(opts.tool)
    if opts.dry_run or opts.action == "plan":
        print(spec["name"], spec["version"], "Lizenz:", spec["license"], "Ziel:", app)
        print("Quelle:", artifact(spec)[0], "Reserve MiB:", spec["reserve_mb"])
        print("Nur Plan, kein Download oder Dateischreiben. Update bleibt auf diesem Release.")
        return 0
    if opts.action in ("status", "check", "doctor"):
        ready, data = False, {}
        try:
            data = validate_record(app, marker, spec, full=opts.action == "doctor")
            ready = True
        except (ValueError, OSError, KeyError, TypeError):
            pass
        print(json.dumps({"installed": ready, "scope": "official-github-release", "runtime_ready": ready and data.get("runtime_ready", False), "service_configured": False}))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool=spec["name"]):
        if opts.action == "uninstall":
            if app.exists() or marker.exists():
                validate_record(app, marker, spec, full=True)
                shutil.rmtree(checked(app))
                marker.unlink()
            print("Nur unveraenderte verwaltete Programmdateien entfernt; Datenbanken, SMTP, Nutzerdaten und Logs bleiben.")
        else:
            install(opts.tool, base, app, marker, spec)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, KeyError, TypeError, subprocess.SubprocessError, tarfile.TarError, zipfile.BadZipFile):
        print("Installation fehlgeschlagen; Details im aktuellen Installationslog. Keine Dienste/DB-Aktionen ausgefuehrt.", file=sys.stderr)
        sys.exit(1)
