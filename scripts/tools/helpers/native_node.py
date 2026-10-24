"""Consent-gated Node/pnpm prerequisites for Zigbee2MQTT; no device access."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from urllib.parse import urlsplit
from urllib.request import HTTPRedirectHandler, build_opener

import gap_tools as common
import native_build_deps as build_deps
import webinar_releases as releases

NODE = "22.23.4"
PNPM = "11.26.0"
# Official nodejs.org SHASUMS256.txt and pnpm GitHub release asset digests.
ASSETS = {
    "linux-amd64": (
        "x64", 56807066, "b8492284c76a54baf58d61668dd0e41ee0fc98adabf9503d30f05d08f55b4406",
        51303707, "9d877d4804bd586dc51f51167fffb0c20e45d97540bffa9b0179701cb51a94c0"),
    "linux-arm64": (
        "arm64", 56697252, "f7a1e486dbc8b286847815b477d4fb5e9fb963ed4489c3e1588853d685f589f9",
        51577662, "61b245dbb66b09c47012b4c37ccb5fee34cc5b7d1e5d5a5b12345adce31ad3ce"),
}


def node_ok(text):
    match = re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)", text)
    if not match:
        return False
    major, minor, _ = map(int, match.groups())
    return (major == 22 and minor >= 13) or major == 24


def confirm(question):
    """Flush a standalone prompt through log pipes; record only the decision."""
    if not sys.stdin.isatty():
        print("Kein interaktives Eingabeterminal; keine automatische Zustimmung.", flush=True)
        return False
    print(question + " [j/N]", flush=True)
    print("Warte auf Eingabe und Enter. Nur j/ja/y/yes erlaubt die Aktion; Enter bedeutet Nein.", flush=True)
    while True:
        try:
            answer = input().strip().lower()
        except EOFError:
            print("Eingabe beendet (EOF); keine Zustimmung erkannt.", flush=True)
            return False
        if answer in ("j", "ja", "y", "yes"):
            print("Zustimmung erteilt.", flush=True)
            return True
        if answer in ("", "n", "nein", "no"):
            print("Keine Zustimmung: " + ("leere Eingabe (Standard Nein)." if not answer else "ausdruecklich abgelehnt."), flush=True)
            return False
        print("Ungueltige Antwort; bitte j oder n eingeben und Enter druecken.", flush=True)


def runtime_version(binary, base, env, allow_repair=False):
    """Repair only the recognized libatomic loader failure after separate consent."""
    try:
        return common.run([str(binary), "--version"], base, env)
    except subprocess.CalledProcessError as error:
        diagnostic = "\n".join(
            part.decode("utf-8", errors="replace") if isinstance(part, bytes) else part
            for part in (error.stdout, error.stderr) if part)
        if error.returncode != 127 or not re.search(
                r"error while loading shared libraries:\s*libatomic\.so\.1:\s*cannot open shared object file",
                diagnostic):
            raise
    apt = ["apt-get", "-o", "DPkg::Lock::Timeout=300", "install", "--no-remove",
           "--no-install-recommends", "-y", "libatomic1"]
    print("Zigbee2MQTT: Node/pnpm braucht die fehlende Laufzeitbibliothek libatomic.so.1 (Paket libatomic1).", flush=True)
    print("Gezielte Reparatur: sudo " + " ".join(apt), flush=True)
    print("Gemeinsame Systembibliothek; apt kann Abhaengigkeiten aktualisieren. "
          "Sie bleibt bei Tool-Deinstallation erhalten; kein System-Node oder Docker.", flush=True)
    policy = os.environ.get("ZIGBEE2MQTT_INSTALL_RUNTIME_LIBS", "ask")
    if policy not in ("ask", "0", "1"):
        raise ValueError("ZIGBEE2MQTT_INSTALL_RUNTIME_LIBS: nur ask, 0 oder 1.")
    supported = build_deps.ubuntu_release() and bool(shutil.which("apt-get"))
    accepted = allow_repair and supported and policy == "1"
    if allow_repair and supported and policy == "ask":
        accepted = confirm("Fehlendes libatomic1 jetzt mit apt installieren?")
    if not accepted:
        raise ValueError("Zigbee2MQTT: libatomic.so.1 fehlt; keine Systemreparatur freigegeben "
                         "oder Plattform nicht Ubuntu 24.04. Bibliothek separat bereitstellen oder "
                         "ZIGBEE2MQTT_INSTALL_RUNTIME_LIBS=1 beim Installieren bewusst setzen. "
                         "Kein erfolgreicher Versions-/Buildnachweis.")
    prefix = [] if getattr(os, "geteuid", lambda: -1)() == 0 else [common.executable("sudo"), "--"]
    system_env = {key: value for key, value in os.environ.items()
                  if key in ("PATH", "LANG", "LC_ALL", "TERM")}
    system_env["DEBIAN_FRONTEND"] = "noninteractive"
    common.run(prefix + apt, base, system_env)
    # Exactly one retry; a successful apt command is not a successful runtime check.
    return common.run([str(binary), "--version"], base, env)


class NodeRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        parts = urlsplit(newurl)
        if parts.scheme != "https" or parts.hostname != "nodejs.org" or parts.username or parts.password:
            raise ValueError("Node-Redirect ausserhalb nodejs.org blockiert.")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def download_node(url, target, size, expected):
    parts = urlsplit(url)
    if parts.scheme != "https" or parts.hostname != "nodejs.org" or parts.username or parts.password:
        raise ValueError("Nicht freigegebene Node-Downloadquelle.")
    total, digest = 0, hashlib.sha256()
    with build_opener(NodeRedirect()).open(url, timeout=30) as response, target.open("xb") as stream:
        while True:
            chunk = response.read(1024**2)
            if not chunk:
                break
            total += len(chunk)
            if total > size:
                raise ValueError("Node-Archiv groesser als freigegeben.")
            digest.update(chunk)
            stream.write(chunk)
    if total != size or digest.hexdigest() != expected:
        raise ValueError("Node-Archivgroesse/SHA256 stimmt nicht.")


def unpack_node(archive, destination, arch):
    # Select only the regular Node executable; never follow npm archive links.
    wanted = "node-v" + NODE + "-linux-" + arch + "/bin/node"
    with tarfile.open(archive, "r:gz") as bundle:
        members = [member for member in bundle.getmembers() if member.name == wanted]
        if len(members) != 1 or not members[0].isfile() or not 0 < members[0].size <= 256 * 1024**2:
            raise ValueError("Node-Programmeinstieg fehlt/unsicher.")
        with bundle.extractfile(members[0]) as source, destination.open("xb") as output:
            shutil.copyfileobj(source, output)
    destination.chmod(0o700)


def select(base, spec, approved=False, allow_download=False):
    recipe = spec["recipe"]
    if not recipe.get("private_node"):
        return None
    if spec["id"] != "zigbee2mqtt" or recipe["private_node"] != NODE or recipe["package_manager"] != PNPM:
        raise ValueError("Nicht freigegebener privater Node/pnpm-Vertrag.")
    env = {key: value for key, value in os.environ.items() if key in ("PATH", "LANG", "LC_ALL")}
    env.update(COREPACK_ENABLE_NETWORK="0", COREPACK_ENABLE_AUTO_PIN="0",
               npm_config_manage_package_manager_versions="false",
               npm_config_userconfig=os.devnull, npm_config_globalconfig=os.devnull,
               npm_config_update_notifier="false")
    node, pnpm = shutil.which("node"), shutil.which("pnpm")
    if node and pnpm:
        try:
            if node_ok(runtime_version(node, base, env, allow_download)) and runtime_version(pnpm, base, env, allow_download) == PNPM:
                print("Zigbee2MQTT: passende vorhandene Node-/pnpm-Werkzeuge.")
                return str(Path(node).parent), str(Path(pnpm).parent)
        except (OSError, subprocess.SubprocessError):
            pass
    key = releases.host_key()
    if key not in ASSETS:
        raise ValueError("Privates Node/pnpm nur fuer Linux amd64/arm64.")
    arch, nsize, nhash, psize, phash = ASSETS[key]
    slot = common.checked(base / "toolchain" / ("node-" + NODE + "-pnpm-" + PNPM + "-" + key))
    app, marker = common.checked(slot / "app"), common.checked(slot / "ready.json")
    record_spec = {"repo": "nodejs/node+pnpm/pnpm", "version": NODE + "+" + PNPM}

    def verify(root, record):
        if record.get("archives") != [nhash, phash]:
            raise ValueError("Node/pnpm-Archivnachweise abweichend.")
        node = releases.entry_path(root, record["entry"])
        pnpm = releases.entry_path(root, record["pnpm_entry"])
        child = {**env, "PATH": str(node.parent) + os.pathsep + env.get("PATH", "")}
        if runtime_version(node, base, child, allow_download) != "v" + NODE:
            raise ValueError("Private Node-Version abweichend.")
        if runtime_version(pnpm, base, child, allow_download) != PNPM:
            raise ValueError("Private pnpm-Version abweichend.")
        return str(node.parent), str(pnpm.parent)

    if slot.exists():
        record = releases.validate_record(app, marker, record_spec, full=True)
        return verify(app, record)
    print("Zigbee2MQTT: passendes Node (22.13+ in Reihe 22 oder 24) / pnpm " + PNPM + " fehlt.")
    print("Gezielt erneut starten: bash scripts/tools/zigbee2mqtt_install.sh --install-build-deps")
    if allow_download and not approved:
        approved = confirm("Node von nodejs.org und pnpm aus GitHub privat bereitstellen?")
    elif allow_download and approved:
        print("Private Node/pnpm-Einrichtung durch --install-build-deps freigegeben.", flush=True)
    if not approved or not allow_download:
        raise ValueError("Zigbee2MQTT: private Node/pnpm-Einrichtung nicht freigegeben. Siehe docs/tools/zigbee2mqtt.md.")
    print("Node/pnpm-Bootstrap: 1024 MiB Puffer zusaetzlich zur Tool-Reserve.")
    releases.reserve(base, {"reserve_mb": recipe["disk_mb"] + 1024})
    with tempfile.TemporaryDirectory(prefix="node-bootstrap-", dir=base) as temporary:
        stage = common.checked(Path(temporary))
        bundle = stage / "bundle"
        payload = bundle / "app"
        (payload / "node").mkdir(parents=True, mode=0o700)
        (payload / "pnpm").mkdir(mode=0o700)
        nurl = "https://nodejs.org/dist/v" + NODE + "/node-v" + NODE + "-linux-" + arch + ".tar.gz"
        purl = "https://github.com/pnpm/pnpm/releases/download/v" + PNPM + "/pnpm-linux-" + arch + ".tar.gz"
        print("Node-Download:", nurl, "Bytes:", nsize, "SHA256:", nhash)
        download_node(nurl, stage / "node.tar.gz", nsize, nhash)
        unpack_node(stage / "node.tar.gz", payload / "node/node", arch)
        print("pnpm-GitHub-Download:", purl, "Bytes:", psize, "SHA256:", phash)
        releases.download(purl, stage / "pnpm.tar.gz", psize, phash)
        releases.unpack(stage / "pnpm.tar.gz", payload / "pnpm")
        candidates = list((payload / "pnpm").rglob("pnpm"))
        candidates = [path for path in candidates if path.is_file()]
        if len(candidates) != 1:
            raise ValueError("pnpm-Programmeinstieg fehlt/mehrdeutig.")
        common.checked(candidates[0]).chmod(0o700)
        record = {**record_spec, "archives": [nhash, phash], "entry": "node/node",
                  "pnpm_entry": candidates[0].relative_to(payload).as_posix(), "hashes": releases.inventory(payload)}
        verify(payload, record)
        (bundle / "ready.json").write_text(json.dumps(record), encoding="utf-8")
        slot.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        if slot.exists():
            raise ValueError("Node/pnpm-Ziel bereits belegt; kein Ueberschreiben.")
        bundle.rename(slot)
    return str(app / "node"), str(releases.entry_path(app, record["pnpm_entry"]).parent)


def prepare(base, spec, approved=False):
    select(base, spec, approved=approved, allow_download=True)


def activate(base, spec, env):
    paths = select(base, spec)
    if paths:
        env["PATH"] = os.pathsep.join((*paths, env.get("PATH", "")))
        env["COREPACK_ENABLE_NETWORK"] = "0"
        env["npm_config_manage_package_manager_versions"] = "false"
