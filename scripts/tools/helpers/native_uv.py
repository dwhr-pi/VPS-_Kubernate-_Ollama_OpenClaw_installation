"""Consent-gated private uv from checked GitHub assets; no Python download."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import gap_tools as common
import webinar_releases as releases

VERSION = "0.13.5"
ARTIFACTS = {
    "linux-amd64": ("uv-x86_64-unknown-linux-gnu.tar.gz", 16682639,
                    "f68d291c75783122dad58ab77def0e13f3233f358731db5d6d7e8715603b928f"),
    "linux-arm64": ("uv-aarch64-unknown-linux-gnu.tar.gz", 15914298,
                    "4bb69cf95ed13f23713bb7bc09f241896ea0c75b7c557e615a20604b82f9c403"),
}


def version_ok(text):
    match = re.fullmatch(r"uv (\d+)\.(\d+)\.(\d+)(?: \([^\n]*\))?", text)
    return bool(match and tuple(map(int, match.groups())) >= (0, 13, 5))


def select(base, spec, approved=False, allow_download=False):
    version = spec["recipe"].get("private_uv")
    if version is None:
        return None
    if spec["id"] != "searxng" or version != VERSION:
        raise ValueError("Nicht freigegebener privater uv-Vertrag.")
    env = {key: value for key, value in os.environ.items() if key in ("PATH", "LANG", "LC_ALL")}
    env.update(UV_PYTHON_DOWNLOADS="never", UV_NO_CONFIG="1")
    binary = shutil.which("uv")
    if binary:
        try:
            suitable = version_ok(common.run([binary, "--version"], base, env))
        except (OSError, subprocess.SubprocessError):
            suitable = False
        if suitable:
            print("SearXNG: passende vorhandene uv-Version:", binary)
            return binary
    key = releases.host_key()
    if key not in ARTIFACTS:
        raise ValueError("Privates uv nur fuer Linux amd64/arm64; uv separat bereitstellen.")
    filename, size, digest = ARTIFACTS[key]
    parent = common.checked(base / "toolchain")
    slot = common.checked(parent / ("uv-" + VERSION + "-" + key))
    app = common.checked(slot / "app")
    marker = common.checked(slot / "release-ready.json")
    record_spec = {"repo": "astral-sh/uv", "version": VERSION}

    def verify(root, record):
        if record.get("artifact_sha256") != digest:
            raise ValueError("Privater uv-Archivnachweis stimmt nicht.")
        executable = releases.entry_path(root, record["entry"])
        actual = common.run([str(executable), "--version"], base, env)
        if not re.fullmatch(r"uv " + re.escape(VERSION) + r"(?: \([^\n]*\))?", actual):
            raise ValueError("Private uv-Version stimmt nicht; keine Aktivierung.")
        return str(executable)

    if slot.exists():
        record = releases.validate_record(app, marker, record_spec, full=True)
        return verify(app, record)
    print("SearXNG: uv fehlt/ist aelter als die gepruefte Baseline " + VERSION + ".")
    print("Gezielt erneut starten: bash scripts/tools/searxng_install.sh --install-build-deps")
    if allow_download and not approved and sys.stdin.isatty():
        print("Privates uv aus offiziellem GitHub-Release, SHA256-geprueft; kein System-Python/PATH-Umbau.", flush=True)
        try:
            approved = input("uv jetzt privat bereitstellen? [j/N]: ").strip().lower() in ("j", "ja", "y", "yes")
        except EOFError:
            approved = False
    if not allow_download or not approved:
        raise ValueError("SearXNG: private uv-Einrichtung nicht freigegeben. Siehe docs/tools/searxng.md.")
    # Account for the archive/extraction before changing any toolchain files.
    print("uv-Bootstrap: 256 MiB Puffer zusaetzlich zur SearXNG-Reserve erforderlich.")
    releases.reserve(base, {"reserve_mb": spec["recipe"]["disk_mb"] + 256})
    url = "https://github.com/astral-sh/uv/releases/download/" + VERSION + "/" + filename
    print("uv-GitHub-Release:", url, "Bytes:", size, "SHA256:", digest)
    with tempfile.TemporaryDirectory(prefix="uv-bootstrap-", dir=base) as temporary:
        stage = common.checked(Path(temporary))
        bundle = stage / "bundle"
        bundle.mkdir(mode=0o700)
        archive, payload = stage / "archive.tar.gz", bundle / "app"
        payload.mkdir(mode=0o700)
        releases.download(url, archive, size, digest)
        releases.unpack(archive, payload)
        candidates = list(payload.rglob("uv"))
        if len(candidates) != 1 or not candidates[0].is_file():
            raise ValueError("uv-Programmeinstieg fehlt/ist nicht eindeutig.")
        binary = common.checked(candidates[0])
        binary.chmod(0o700)
        record = {**record_spec, "artifact_sha256": digest,
                  "entry": binary.relative_to(payload).as_posix(), "hashes": releases.inventory(payload)}
        verify(payload, record)
        (bundle / "release-ready.json").write_text(json.dumps(record), encoding="utf-8")
        parent.mkdir(mode=0o700, exist_ok=True)
        if slot.exists():
            raise ValueError("uv-Ziel zwischenzeitlich belegt; nichts ueberschreiben.")
        bundle.rename(slot)
    print("Private uv-Basis bereit; kein Python-Download, Server oder Suchauftrag gestartet.")
    return str(releases.entry_path(app, record["entry"]))


def prepare(base, spec, approved=False):
    select(base, spec, approved=approved, allow_download=True)


def activate(base, spec, env):
    if spec["recipe"].get("private_uv"):
        binary = select(base, spec)
        env["PATH"] = str(Path(binary).parent) + os.pathsep + env.get("PATH", "")
        env["UV_NO_CONFIG"] = "1"
        env["UV_PYTHON_DOWNLOADS"] = "never"
