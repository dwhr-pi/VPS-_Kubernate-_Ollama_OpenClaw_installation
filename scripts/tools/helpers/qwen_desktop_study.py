"""Pinned Qwen Desktop study sources with an optional, separate development build."""
import argparse
import json
from pathlib import PurePosixPath
import platform
import shutil
import subprocess
import sys

import gap_tools as common
from browseros_study import digest

KEY = 'qwen_desktop_study'
SPEC = common.SPECS[KEY]
PURPOSE = 'Fuer Studienzwecke und Weiterentwicklung; experimentell, keine Produktionsfreigabe.'


def artifact(base, relative):
    path = PurePosixPath(relative)
    prefix = 'packages/desktop/'
    if (path.is_absolute() or '..' in path.parts or '\\' in relative or ':' in relative
            or not relative.startswith(prefix)):
        raise ValueError('Ungueltiger Qwen-Buildpfad.')
    return common.checked(base / 'development/source' / relative)


def build_status(base):
    marker = common.checked(base / 'desktop-build.json')
    if not marker.exists():
        return False
    data = json.loads(marker.read_text(encoding='utf-8'))
    entries = data.get('entries', {})
    return (data.get('pin') == SPEC['pin'] and data.get('platform') in ('Linux', 'Windows')
            and bool(entries) and all(digest(artifact(base, name)) == value for name, value in entries.items()))


def preflight(base):
    if platform.system() not in ('Linux', 'Windows'):
        raise ValueError('Qwen Desktop: Linux/WSL oder natives Windows erforderlich.')
    common.reserve(base, {'reserve_mb': 20480})
    for name in ('node', 'npm', 'corepack', 'cargo', 'rustc', 'tar'):
        common.executable(name)


def build(base, runtime, marker):
    common.validate(runtime, marker, SPEC, full=True)
    if (base / 'desktop-build.json').exists():
        if build_status(base):
            print('Qwen-Desktop-Buildnachweis geprueft; kein Neubau/Start.')
            return
        raise ValueError('Ungueltiger Buildnachweis; nichts ueberschreiben.')
    preflight(base)
    development = common.checked(base / 'development')
    if development.exists():
        raise ValueError('Entwicklungsdaten vorhanden; zuerst sichern/pruefen, nichts ueberschreiben.')
    development.mkdir(mode=0o700)
    source = common.checked(development / 'source')
    shutil.copytree(runtime, source, symlinks=True)
    env = common.build_env(development)
    # Reuse the existing pinned Tauri contract, never run the resulting desktop app.
    entries = common.qwen_build(source, env)
    record = {'pin': SPEC['pin'], 'platform': platform.system(), 'purpose': PURPOSE,
              'scope': 'desktop-build', 'application_tested': False,
              'entries': {name: digest(artifact(base, name)) for name in entries}}
    with (base / 'desktop-build.json').open('x', encoding='utf-8') as stream:
        json.dump(record, stream)
    print('Lokales unsigniertes Desktop-Paket gebaut; nicht installiert oder gestartet.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['install', 'update', 'uninstall', 'status', 'check', 'doctor', 'plan'])
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--build-desktop', action='store_true')
    args = parser.parse_args(argv)
    base, runtime, marker = common.paths(KEY)
    print(PURPOSE)
    if args.dry_run or args.action == 'plan':
        print(json.dumps(dict(**SPEC, target=str(runtime), desktop_build=args.build_desktop,
                              build_reserve_mb=20480), indent=2))
        print('Nur Plan; kein Download, Build oder Anwendungsstart.')
        return 0
    if args.action in ('status', 'check', 'doctor'):
        ready, built = False, False
        try:
            common.validate(runtime, marker, SPEC, full=args.action == 'doctor')
            ready = True
            built = build_status(base)
        except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
            pass
        print(json.dumps({'installed': ready, 'scope': 'study-sources', 'desktop_built': built,
                          'application_tested': False}))
        return 0 if args.action == 'status' or (ready and (args.action != 'doctor' or
                   not (base / 'desktop-build.json').exists() or built)) else 1
    full = args.build_desktop
    if full and args.action not in ('install', 'update'):
        raise ValueError('--build-desktop nur fuer Install/Update oder Plan.')
    if args.action == 'install' and not full and sys.stdin.isatty():
        print('1: nur Studienquellen (Standard); 2: zusaetzlich Qwen Desktop bauen')
        if input('Auswahl [1]: ').strip() == '2':
            print('Build braucht mindestens 20 GiB freien Speicher; Abhaengigkeiten werden heruntergeladen.')
            full = input('Desktop-Build freigeben? [j/N]: ').strip().lower() in ('j', 'ja', 'y', 'yes')
    with common.operation(base, args.action, tool=SPEC['name']):
        if args.action == 'uninstall':
            if (base / 'development').exists() or (base / 'desktop-build.json').exists():
                raise ValueError('Entwicklungs-/Builddaten vorhanden; zuerst sichern/pruefen, nichts loeschen.')
            if runtime.exists() or marker.exists():
                common.validate(runtime, marker, SPEC, full=True)
                shutil.rmtree(common.checked(runtime))
                marker.unlink()
            print('Unveraenderte Studienquellen entfernt; Logs und Basiswerkzeuge bleiben.')
        else:
            if full:
                preflight(base)
            common.install(runtime, marker, base, SPEC)
            if full:
                build(base, runtime, marker)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError, EOFError) as error:
        print('Qwen_Desktop_Study fehlgeschlagen/abgebrochen:', error, file=sys.stderr)
        print('Vorhandene Studien-/Entwicklungsdaten bleiben erhalten.', file=sys.stderr)
        sys.exit(1)
