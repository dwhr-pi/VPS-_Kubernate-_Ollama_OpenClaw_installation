"""Minisign-verankertes Release pruefen; kein Download, Login oder Schluesselimport."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

REPO = 'https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git'
TAG = re.compile(r'v[0-9]+\.[0-9]+\.[0-9]+(?:-[a-zA-Z0-9.-]+)?')


def unique(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Doppelter Metadaten-Schluessel.')
        result[key] = value
    return result


def regular(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file() or not 0 < path.stat().st_size <= 1048576:
        raise ValueError('Kleine regulaere Release-Datei erforderlich.')
    return path


def verify(directory, tag, public_key, runner=None):
    if not TAG.fullmatch(tag):
        raise ValueError('Expliziter versionierter Release-Tag erforderlich.')
    directory = Path(directory).resolve(strict=True)
    key = regular(public_key).resolve(strict=True)
    if key.is_relative_to(directory):
        raise ValueError('Vertrauensschluessel muss unabhaengig vom Release-Verzeichnis bereitstehen.')
    files = {name: regular(directory / name) for name in
             ('SHA256SUMS', 'SHA256SUMS.minisig', 'release.json', 'install.sh')}
    env = {name: value for name, value in os.environ.items() if name in ('PATH', 'LANG', 'LC_ALL', 'SYSTEMROOT')}
    result = (runner or subprocess.run)(
        ['minisign', '-Vm', str(files['SHA256SUMS']), '-p', str(key), '-x', str(files['SHA256SUMS.minisig'])],
        env=env, capture_output=True, timeout=30, check=False)
    if result.returncode:
        raise ValueError('Release-Signatur ungueltig; nichts ausfuehren.')
    checksums = {}
    for line in files['SHA256SUMS'].read_text(encoding='ascii').splitlines():
        match = re.fullmatch(r'([a-f0-9]{64})  (install\.sh|release\.json)', line)
        if not match or match[2] in checksums or match[1] == '0' * 64:
            raise ValueError('Unbekannte, doppelte oder unsichere Pruefsummenzeile.')
        checksums[match[2]] = match[1]
    if set(checksums) != {'install.sh', 'release.json'}:
        raise ValueError('Unvollstaendige Release-Pruefsummen.')
    for name, digest in checksums.items():
        if hashlib.sha256(files[name].read_bytes()).hexdigest() != digest:
            raise ValueError('Release-Pruefsumme stimmt nicht.')
    data = json.loads(files['release.json'].read_text(encoding='utf-8'), object_pairs_hook=unique)
    if (not isinstance(data, dict) or set(data) != {'schema_version', 'tag', 'commit', 'repo'} or
            data['schema_version'] != 1 or data['tag'] != tag or data['repo'] != REPO or
            not isinstance(data['commit'], str) or not re.fullmatch(r'[a-f0-9]{40}', data['commit']) or
            data['commit'] == '0' * 40):
        raise ValueError('Signierter Tag-/Commit-/Repository-Vertrag passt nicht.')
    return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--artifacts', required=True, type=Path)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--public-key', required=True, type=Path)
    args = parser.parse_args()
    try:
        print(json.dumps(verify(args.artifacts, args.tag, args.public_key)))
    except (ValueError, OSError, subprocess.SubprocessError):
        print('Release-Pruefung fehlgeschlagen: Dateien, Tag, unabhaengigen Minisign-Schluessel und Signatur pruefen. Kein Fallback.', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
