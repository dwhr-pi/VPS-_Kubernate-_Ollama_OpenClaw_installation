"""Private Node/npm for Node-RED; no global install or application start."""
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tarfile
import tempfile

import gap_tools as common
import native_node as node
import webinar_releases as releases

NPM = "10.9.9"


def unpack(archive, payload, arch):
    node.unpack_node(archive, payload / "node", arch)
    prefix = "node-v" + node.NODE + "-linux-" + arch + "/lib/node_modules/npm/"
    total, count = 0, 0
    with tarfile.open(archive, "r:gz") as bundle:
        for member in bundle:
            if not member.name.startswith(prefix):
                continue
            relative = PurePosixPath(member.name[len(prefix):])
            if relative.is_absolute() or ".." in relative.parts or "\\" in str(relative):
                raise ValueError("Unsicherer npm-Archivpfad.")
            if member.isdir():
                continue
            # Do not extract archive links, devices or install-time launchers.
            if not member.isfile():
                raise ValueError("Nicht regulaerer npm-Archiveintrag.")
            total += member.size
            count += 1
            if member.size < 0 or total > 512 * 1024**2 or count > 20000:
                raise ValueError("npm-Archivgrenze ueberschritten.")
            target = common.checked(payload / "npm-package" / relative)
            target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
            with bundle.extractfile(member) as source, target.open("xb") as output:
                shutil.copyfileobj(source, output)
            target.chmod(0o600)
    metadata = json.loads((payload / "npm-package/package.json").read_text(encoding="utf-8"))
    if metadata.get("version") != NPM or not (payload / "npm-package/bin/npm-cli.js").is_file():
        raise ValueError("Erwartetes gebuendeltes npm fehlt/abweichend.")
    launcher = payload / "npm"
    launcher.write_text('#!/bin/sh\nexec "${0%/*}/node" "${0%/*}/npm-package/bin/npm-cli.js" "$@"\n', encoding="ascii")
    launcher.chmod(0o700)


def select(base, spec, approved=False, allow_download=False):
    version = spec["recipe"].get("private_node_npm")
    if version is None:
        return None
    if spec["id"] != "node_red" or version != node.NODE:
        raise ValueError("Nicht freigegebener privater Node/npm-Vertrag.")
    env = {k: v for k, v in os.environ.items() if k in ("PATH", "LANG", "LC_ALL")}
    env.update(npm_config_userconfig=os.devnull, npm_config_globalconfig=os.devnull,
               npm_config_update_notifier="false", COREPACK_ENABLE_NETWORK="0")
    binary, npm = shutil.which("node"), shutil.which("npm")
    if binary and npm:
        try:
            child = {**env, "PATH": str(Path(binary).parent) + os.pathsep + env.get("PATH", "")}
            if node.node_ok(common.run([binary, "--version"], base, child)) and common.run([npm, "--version"], base, child) == NPM:
                print("Node-RED: passende vorhandene Node/npm-Basis.")
                return str(Path(binary).parent), str(Path(npm).parent)
        except (OSError, subprocess.SubprocessError):
            pass
    key = releases.host_key()
    if key not in node.ASSETS:
        raise ValueError("Private Node/npm-Basis nur fuer Linux amd64/arm64.")
    arch, size, digest, _, _ = node.ASSETS[key]
    slot = common.checked(base / "toolchain" / ("node-" + node.NODE + "-npm-" + NPM + "-" + key))
    app, marker = slot / "app", slot / "ready.json"
    record_spec = {"repo": "nodejs/node", "version": node.NODE + "+npm" + NPM}

    def verify(payload, record):
        if record.get("artifact_sha256") != digest:
            raise ValueError("Node/npm-Archivnachweis abweichend.")
        child = {**env, "PATH": str(payload) + os.pathsep + env.get("PATH", "")}
        if node.runtime_version(payload / "node", base, child, allow_download,
                                tool_name="Node-RED", policy_name="NODE_RED_INSTALL_RUNTIME_LIBS") != "v" + node.NODE:
            raise ValueError("Private Node-Version abweichend.")
        if node.runtime_version(payload / "npm", base, child, allow_download,
                                tool_name="Node-RED", policy_name="NODE_RED_INSTALL_RUNTIME_LIBS") != NPM:
            raise ValueError("Private npm-Version abweichend.")
        return str(payload), str(payload)

    if slot.exists():
        record = releases.validate_record(app, marker, record_spec, full=True)
        return verify(app, record)
    print("Node-RED: passende Node/npm-Basis fehlt. Siehe docs/tools/node-red.md.")
    print("Gezielt erneut starten: bash scripts/tools/node_red_install.sh --install-build-deps")
    if allow_download and not approved:
        approved = node.confirm("Node und gebuendeltes npm von nodejs.org privat bereitstellen?")
    if not allow_download or not approved:
        raise ValueError("Node-RED: privater Node/npm-Download nicht freigegeben.")
    releases.reserve(base, {"reserve_mb": spec["recipe"]["disk_mb"] + 1024})
    url = "https://nodejs.org/dist/v" + node.NODE + "/node-v" + node.NODE + "-linux-" + arch + ".tar.gz"
    print("Node/npm-Download:", url, "Bytes:", size, "SHA256:", digest)
    with tempfile.TemporaryDirectory(prefix="node-npm-bootstrap-", dir=base) as temporary:
        stage = common.checked(Path(temporary))
        payload = stage / "bundle/app"
        payload.mkdir(parents=True, mode=0o700)
        node.download_node(url, stage / "node.tar.gz", size, digest)
        unpack(stage / "node.tar.gz", payload, arch)
        record = {**record_spec, "artifact_sha256": digest, "entry": "node",
                  "hashes": releases.inventory(payload)}
        verify(payload, record)
        (payload.parent / "ready.json").write_text(json.dumps(record), encoding="utf-8")
        slot.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        if slot.exists():
            raise ValueError("Node/npm-Ziel bereits belegt; kein Ueberschreiben.")
        payload.parent.rename(slot)
    return str(app), str(app)


def prepare(base, spec, approved=False):
    select(base, spec, approved=approved, allow_download=True)


def activate(base, spec, env):
    paths = select(base, spec)
    if paths:
        env["PATH"] = os.pathsep.join((*dict.fromkeys(paths), env.get("PATH", "")))
        env["COREPACK_ENABLE_NETWORK"] = "0"
