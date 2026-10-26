"""Optional BrowserOS sources and guarded experimental Linux Chromium build."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys

import gap_tools as common
import native_build_process as process

KEY = 'browseros_study'
SPEC = common.SPECS[KEY]
PURPOSE = 'Fuer Studienzwecke und Weiterentwicklung; experimentell, keine Produktionsfreigabe.'


def digest(path):
    value = hashlib.sha256()
    with common.checked(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()


def build_status(base):
    marker = common.checked(base / 'browser-build.json')
    if not marker.exists():
        return False
    data = json.loads(marker.read_text(encoding='utf-8'))
    name = data['artifact']
    if not re.fullmatch(r'chromium/src/out/[A-Za-z0-9_.-]+/chrome', name):
        raise ValueError('Ungueltiger BrowserOS-Buildartefaktpfad.')
    return data.get('pin') == SPEC['pin'] and digest(base / name) == data.get('sha256')


def preflight(base, confirmed):
    if not confirmed:
        raise ValueError('Build veraendert den separaten Chromium-Checkout. --confirm-chromium-changes erforderlich.')
    if platform.system() != 'Linux' or platform.machine().lower() not in ('x86_64', 'amd64'):
        raise ValueError('Experimenteller Vollbuild nur Linux/WSL x86_64; kein Windows-Crossbuild.')
    common.reserve(base, {'reserve_mb': 102400})
    memory = dict(line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(memory['MemAvailable'].split()[0]) < 16 * 1024**2:
        raise ValueError('BrowserOS-Vollbuild: mindestens 16 GiB verfuegbarer RAM erforderlich.')
    chromium = common.checked(base / 'chromium/src')
    common.checked(chromium / '.git')
    if not (chromium / '.git').is_dir():
        raise ValueError('Separaten Chromium-Checkout vorher bewusst unter tools/browseros_study/chromium/src vorbereiten.')
    depot = common.checked(base / 'chromium/depot_tools')
    for name in ('gclient', 'gn', 'autoninja'):
        if not common.checked(depot / name).is_file():
            raise ValueError('Separat bereitgestellte depot_tools fehlen: ' + name)
    for name in ('uv', 'bun', 'cargo', 'rustc', 'cc', 'c++', 'make', 'pkg-config'):
        common.executable(name)
    python = os.environ.get('BROWSEROS_STUDY_PYTHON_BIN', sys.executable)
    common.run([python, '-I', '-c', 'import sys,ssl; assert sys.version_info >= (3,12)'], base,
               {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')})
    return chromium, depot, python


def build(base, runtime, marker, confirmed):
    common.validate(runtime, marker, SPEC)
    if (base / 'browser-build.json').exists():
        if build_status(base):
            print('Vorhandenes Browser-Buildartefakt geprueft; kein erneuter Build/Start.')
            return
        raise ValueError('Vorhandener Buildnachweis ungueltig; nichts ueberschreiben.')
    common.validate(runtime, marker, SPEC, full=True)
    chromium, depot, python = preflight(base, confirmed)
    expected = (runtime / 'packages/browseros/BASE_COMMIT').read_text().strip()
    if not re.fullmatch(r'[0-9a-f]{40}', expected) or common.git(chromium, 'rev-parse', 'HEAD') != expected:
        raise ValueError('Chromium-HEAD passt nicht zum BrowserOS-BASE_COMMIT; kein Reset/Checkout durch das Setup.')
    if common.git(chromium, 'status', '--porcelain', '--untracked-files=all'):
        raise ValueError('Chromium-Checkout nicht leer/pristin; separate frische Entwicklungskopie verwenden.')
    module = runtime / 'packages/browseros'
    development = common.checked(base / 'development')
    if development.exists():
        raise ValueError('Entwicklungsordner bereits vorhanden; eigene Arbeit erhalten, kein automatisches Ueberschreiben.')
    development.mkdir(mode=0o700)
    env = common.build_env(development)
    env.update(PATH=str(depot) + os.pathsep + env.get('PATH', ''), UV_PYTHON_DOWNLOADS='never',
               UV_NO_CONFIG='1', RUSTUP_AUTO_INSTALL='0', CARGO_BUILD_JOBS='1', UV_CONCURRENT_BUILDS='1')
    # Block accidental privileged/container fallbacks; no inherited API/signing/upload secrets.
    guards = development / 'guards'
    guards.mkdir(exist_ok=True, mode=0o700)
    for name in ('sudo', 'docker', 'podman'):
        target = common.checked(guards / name)
        if target.exists():
            raise ValueError('Vorhandener Build-Guard: Entwicklungsordner bewusst pruefen, kein Ueberschreiben.')
        target.write_text('#!/bin/sh\nexit 126\n', encoding='ascii')
        target.chmod(0o700)
    env['PATH'] = str(guards) + os.pathsep + env['PATH']
    package = json.loads((runtime / 'packages/browseros-agent/package.json').read_text())
    manager = package['packageManager']
    if not manager.startswith('bun@') or common.run(['bun', '--version'], module, env) != manager[4:]:
        raise ValueError('Vorhandenes Bun stimmt nicht mit packages/browseros-agent/package.json ueberein.')
    venv = development / 'venv'
    common.run(['uv', 'venv', '--python', python, '--no-python-downloads', str(venv)], module, env)
    process.run(['uv', 'pip', 'install', '--python', str(venv / 'bin/python'), '--index-url',
                 'https://pypi.org/simple', str(module)], module, env)
    cli = venv / 'bin/browseros'
    args = [str(cli), 'build', '--preset', 'release', '--product', 'browseros',
            '--resource-mode', 'source', '--source-sha', SPEC['pin'], '--provision', 'none',
            '--no-clean', '--no-sign', '--no-upload', '--chromium-src', str(chromium)]
    process.run(args + ['--show-plan'], module, env)
    print('Experimenteller Vollbuild: Quellen/Chromium koennen veraendert werden; kein Upload/Browserstart.', flush=True)
    process.run(args, module, env, timeout=21600)
    outputs = [path for path in chromium.glob('out/*/chrome') if path.is_file()]
    if len(outputs) != 1:
        raise ValueError('Genau ein Linux-Browserartefakt erwartet; kein erfolgreicher Buildnachweis.')
    data = {'pin': SPEC['pin'], 'artifact': outputs[0].relative_to(base).as_posix(),
            'sha256': digest(outputs[0]), 'purpose': PURPOSE, 'application_tested': False}
    with (base / 'browser-build.json').open('x', encoding='utf-8') as stream:
        json.dump(data, stream)
    print('Browserartefakt erstellt/gehasht; GUI, Sandbox und Laufzeit noch separat abnehmen.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['install', 'update', 'uninstall', 'status', 'check', 'doctor', 'plan'])
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--build-browser', action='store_true')
    parser.add_argument('--confirm-chromium-changes', action='store_true')
    args = parser.parse_args(argv)
    base, runtime, marker = common.paths(KEY)
    print(PURPOSE)
    if args.dry_run or args.action == 'plan':
        print(json.dumps(dict(**SPEC, target=str(runtime), full_build=args.build_browser,
                              full_build_reserve_mb=102400, full_build_ram_gib=16), indent=2))
        print('Nur Plan; kein Download/Build/Browserstart. Standard: nur Studienquellen.')
        return 0
    if args.action in ('status', 'check', 'doctor'):
        ready = False
        try:
            common.validate(runtime, marker, SPEC, full=args.action == 'doctor')
            ready = True
        except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
            pass
        print(json.dumps({'installed': ready, 'scope': 'study-sources', 'browser_built': build_status(base) if ready else False,
                          'application_tested': False}))
        return 0 if ready or args.action == 'status' else 1
    full = args.build_browser
    confirmed = args.confirm_chromium_changes
    if args.action == 'install' and not full and sys.stdin.isatty():
        print('1: nur GitHub-Quellen fuer Studien/Weiterentwicklung (Standard); 2: experimenteller Chromium-Vollbuild')
        full = input('Auswahl [1]: ').strip() == '2'
        if full:
            confirmed = input('Chromium wird veraendert; >=100 GiB frei / >=16 GiB RAM. Bewusst bauen? [j/N]: ').strip().lower() in ('j', 'ja', 'y', 'yes')
    if full and args.action not in ('install', 'update'):
        raise ValueError('--build-browser nur fuer Install/Update oder Plan.')
    with common.operation(base, args.action, tool='BrowserOS_Study'):
        if full:
            preflight(base, confirmed)  # Reject unavailable resources before the source download.
        if args.action == 'uninstall':
            if (base / 'development').exists() or (base / 'browser-build.json').exists():
                raise ValueError('Entwicklungs-/Builddaten vorhanden: manuell sichern/pruefen, nichts loeschen.')
            if runtime.exists() or marker.exists():
                common.validate(runtime, marker, SPEC, full=True)
                common.shutil.rmtree(common.checked(runtime))
                marker.unlink()
            print('Unveraenderte Studienquellen entfernt; Chromium, Profile und Logs bleiben.')
        else:
            common.install(runtime, marker, base, SPEC)
            if full:
                build(base, runtime, marker, confirmed)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError, EOFError) as error:
        print('BrowserOS_Study fehlgeschlagen/abgebrochen:', error, file=sys.stderr)
        print('Vorhandene Studien-/Chromium-/Builddaten bleiben zur Weiterentwicklung erhalten.', file=sys.stderr)
        sys.exit(1)
