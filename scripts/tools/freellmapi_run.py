"""Strict private ENV reader/foreground launcher. No shell, downloads or service edits."""
import argparse
import os
from pathlib import Path
import re
import sys

ALLOWED = {'ENCRYPTION_KEY', 'FREELLMAPI_CONTEXT_HANDOFF', 'FREELLMAPI_UPDATE_CHECK'}


def read_env(filename):
    path = Path(filename)
    if path.is_symlink() or path.resolve() != path.absolute() or not path.is_file():
        raise ValueError('ENV fehlt oder enthaelt einen Symlink.')
    if os.name != 'nt' and (path.stat().st_mode & 0o077 or path.stat().st_uid != os.getuid()):
        raise ValueError('ENV braucht Benutzerbesitz und Rechte 0600.')
    if path.stat().st_size > 16384:
        raise ValueError('ENV ist zu gross.')
    values = {}
    for line in path.read_text(encoding='utf-8-sig').splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        match = re.fullmatch(r'\s*([A-Z_]+)\s*=\s*(.*?)\s*', line)
        if not match or match[1] not in ALLOWED or match[1] in values:
            raise ValueError('Unbekannte/doppelte ENV-Eintraege.')
        value = match[2]
        if value.startswith(("'", '"')):
            if len(value) < 2 or value[-1] != value[0]:
                raise ValueError('ENV-Format ungueltig.')
            value = value[1:-1]
        values[match[1]] = value
    if not re.fullmatch(r'[0-9a-fA-F]{64}', values.get('ENCRYPTION_KEY', '')):
        raise ValueError('ENCRYPTION_KEY braucht 64 Hex-Zeichen.')
    if values.get('FREELLMAPI_CONTEXT_HANDOFF', 'off') not in ('off', 'on_model_switch'):
        raise ValueError('Context-Handoff-Wert ungueltig.')
    if values.get('FREELLMAPI_UPDATE_CHECK', 'off') != 'off':
        raise ValueError('Update-Erkennung bleibt off.')
    return values


def runtime_env(values, source, data, port):
    env = {key: value for key, value in os.environ.items()
           if key in {'PATH', 'HOME', 'LANG', 'LC_ALL', 'TMPDIR', 'SYSTEMROOT'}}
    env.update(values)
    env.update(NODE_ENV='production', HOST='127.0.0.1', PORT=str(port),
               FREEAPI_DB_PATH=str(data / 'freeapi.db'), FREEAPI_DB_DIR_HARDENING='1',
               CLIENT_DIST=str(source / 'client/dist'), FREEAPI_ENV_PATH=os.devnull,
               FREELLMAPI_UPDATE_CHECK='off')
    return env


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-env', action='store_true')
    parser.add_argument('--env-file', required=True)
    parser.add_argument('--source-dir')
    parser.add_argument('--data-dir')
    parser.add_argument('--node')
    parser.add_argument('--port', type=int, default=3011)
    args = parser.parse_args(argv)
    try:
        values = read_env(args.env_file)
        if args.check_env:
            print('Private ENV formal gueltig; keine Schluesselwerte ausgegeben.')
            return 0
        if not all((args.source_dir, args.data_dir, args.node)) or not 1 <= args.port <= 65535:
            raise ValueError('Startargumente fehlen/ungueltig.')
        source, data = Path(args.source_dir), Path(args.data_dir)
        if not all(p.is_absolute() and p.resolve() == p for p in (source, data)):
            raise ValueError('Nur absolute symlinkfreie Runtime-Pfade.')
        entry = source / 'server/dist/index.js'
        if not entry.is_file():
            raise ValueError('Source-Build fehlt.')
        data.mkdir(mode=0o700, parents=True, exist_ok=True)
        if os.name != 'nt' and data.stat().st_mode & 0o077:
            raise ValueError('Datenverzeichnis braucht Rechte 0700.')
        os.chdir(source)
        os.execve(args.node, [args.node, str(entry)], runtime_env(values, source, data, args.port))
    except (OSError, ValueError):
        print('Abgebrochen: private ENV/Rechte, Build und Runtime-Pfade pruefen. Keine Secret-Werte ausgegeben.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
