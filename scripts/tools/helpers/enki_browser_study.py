"""Enki study sources and optional upstream packaging, not a Chromium source build."""
import argparse
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
from urllib.parse import urlsplit

import gap_tools as common
import native_build_process as process
from browseros_study import digest

KEY = 'enki_browser_study'
SPEC = common.SPECS[KEY]
PURPOSE = 'Fuer Studienzwecke und Weiterentwicklung; experimentell, keine Produktionsfreigabe.'


def artifact_name(version, system):
    if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+', version):
        raise ValueError('Ungueltige Enki-Paketversion.')
    name = ('EnkiBrowserSetup-' + version + '.exe' if system == 'Windows' else
            'enki-browser-' + version + '-linux-x64.tar.gz')
    return 'development/source/out/' + name


def build_status(base):
    marker = common.checked(base / 'package-build.json')
    if not marker.exists():
        return False
    data = json.loads(marker.read_text(encoding='utf-8'))
    if data.get('platform') not in ('Linux', 'Windows') or data['artifact'] != artifact_name(data['version'], data['platform']):
        raise ValueError('Unbekannter Enki-Paketpfad.')
    return data.get('pin') == SPEC['pin'] and digest(base / data['artifact']) == data.get('sha256')


def preflight(base, accepted):
    if not accepted:
        raise ValueError('Enki nutzt fertige Chromium-/Drittanbieter-Binaerpakete. --accept-pinned-binaries erforderlich.')
    system = platform.system()
    if system not in ('Linux', 'Windows') or platform.machine().lower() not in ('x86_64', 'amd64'):
        raise ValueError('Enki-Paketbuild derzeit nur Linux/WSL x86_64 oder natives Windows x64.')
    common.reserve(base, {'reserve_mb': 8192})
    if system == 'Linux':
        memory = dict(line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())
        if int(memory['MemAvailable'].split()[0]) < 4 * 1024**2:
            raise ValueError('Enki-Paketbuild: mindestens 4 GiB verfuegbarer RAM erforderlich.')
        for name in ('tar', 'xz', 'unzip'):
            common.executable(name)
    else:
        windows = Path(os.environ.get('WINDIR', r'C:\Windows'))
        if not (windows / 'System32/tar.exe').is_file() or not any(
                (windows / 'Microsoft.NET' / arch / 'v4.0.30319/csc.exe').is_file()
                for arch in ('Framework64', 'Framework')):
            raise ValueError('Natives Windows: System-tar.exe und .NET-Framework-C#-Compiler erforderlich.')
    node = common.executable('node')
    env = {key: value for key, value in os.environ.items() if key in ('PATH', 'SystemRoot', 'SYSTEMROOT', 'LANG', 'LC_ALL')}
    version = common.run([node, '--version'], base, env)
    if not re.fullmatch(r'v(?:2[2-9]|[3-9][0-9])\.[0-9]+\.[0-9]+', version):
        raise ValueError('Enki-Build braucht vorhandenes Node >=22; kein automatischer Bootstrap.')
    return system, node, common.node_command('npm')


def validate_inputs(runtime, system):
    data = json.loads((runtime / 'upstream.json').read_text())
    names = ['chromiumLinux', 'blocker'] if system == 'Linux' else ['chromium', 'blocker', 'rcedit']
    for name in names:
        item = data[name]
        url = urlsplit(item['url'])
        if (url.scheme != 'https' or url.hostname != 'github.com' or url.username or url.password or
                '/releases/download/' not in url.path or not re.fullmatch(r'[0-9a-f]{64}', item['sha256'])):
            raise ValueError('Enki-Upstream-Download ohne geprueften GitHub-/SHA256-Vertrag.')


def build(base, runtime, marker, accepted):
    common.validate(runtime, marker, SPEC, full=True)
    if (base / 'package-build.json').exists():
        if build_status(base):
            print('Vorhandenes Enki-Paket geprueft; kein Neubau/Start.')
            return
        raise ValueError('Vorhandener Paketnachweis ungueltig; nichts ueberschreiben.')
    system, node, npm = preflight(base, accepted)
    validate_inputs(runtime, system)
    development = common.checked(base / 'development')
    if development.exists():
        raise ValueError('Entwicklungsdaten schon vorhanden; zuerst sichern/pruefen, nichts ueberschreiben.')
    development.mkdir(mode=0o700)
    source = common.checked(development / 'source')
    shutil.copytree(runtime, source, symlinks=True)
    for relative in ('out', 'cache', 'node_modules', 'extension/dist', 'extension/node_modules'):
        common.checked(source / relative)
    env = common.build_env(development)
    env.update(ENKI_DIST=str(source / 'extension/dist'), npm_config_ignore_scripts='true',
               npm_config_globalconfig=str(development / 'global-empty.npmrc'))
    (development / 'global-empty.npmrc').write_text('', encoding='ascii')
    if system == 'Windows':
        env['WINDIR'] = os.environ.get('WINDIR', r'C:\Windows')
    else:
        guards = development / 'guards'
        guards.mkdir(mode=0o700)
        for name in ('sudo', 'docker', 'podman'):
            target = guards / name
            target.write_text('#!/bin/sh\nexit 126\n', encoding='ascii')
            target.chmod(0o700)
        env['PATH'] = str(guards) + os.pathsep + env.get('PATH', '')
    # Build the extension explicitly; upstream then reuses ENKI_DIST instead of shell npm calls.
    for folder in (source, source / 'extension'):
        process.run(npm + ['ci', '--ignore-scripts', '--no-audit', '--no-fund'], folder, env)
    process.run(npm + ['run', 'build'], source / 'extension', env)
    script = 'build/build.mjs' if system == 'Windows' else 'build/build-linux.mjs'
    print('Enki: Erweiterungs-/Paketbuild mit gepinnten Chromium-Binaerdateien, KEIN Chromium-Source-Build.', flush=True)
    process.run([node, script], source, env, timeout=14400)
    version = json.loads((source / 'package.json').read_text())['version']
    artifact = artifact_name(version, system)
    record = {'pin': SPEC['pin'], 'artifact': artifact, 'sha256': digest(base / artifact),
              'version': version, 'platform': system, 'purpose': PURPOSE,
              'scope': 'source-extension-plus-pinned-binary-packaging', 'application_tested': False}
    with (base / 'package-build.json').open('x', encoding='utf-8') as stream:
        json.dump(record, stream)
    print('Enki-Paket erstellt/gehasht. Nicht installiert, gestartet oder als getestete Anwendung freigegeben.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['install', 'update', 'uninstall', 'status', 'check', 'doctor', 'plan'])
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--build-browser', action='store_true')
    parser.add_argument('--accept-pinned-binaries', action='store_true')
    args = parser.parse_args(argv)
    base, runtime, marker = common.paths(KEY)
    print(PURPOSE)
    if args.dry_run or args.action == 'plan':
        print(json.dumps(dict(**SPEC, target=str(runtime), package_build=args.build_browser,
                              package_build_reserve_mb=8192, chromium_source_build=False), indent=2))
        print('Nur Plan; Standard nur Studienquellen, kein Download/Build/Browserstart.')
        return 0
    if args.action in ('status', 'check', 'doctor'):
        ready = False
        try:
            common.validate(runtime, marker, SPEC, full=args.action == 'doctor')
            ready = True
        except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
            pass
        print(json.dumps({'installed': ready, 'scope': 'study-sources', 'package_built': build_status(base) if ready else False,
                          'application_tested': False}))
        return 0 if ready or args.action == 'status' else 1
    full, accepted = args.build_browser, args.accept_pinned_binaries
    if args.action == 'install' and not full and sys.stdin.isatty():
        print('1: nur Studienquellen (Standard); 2: Erweiterung bauen / mit gepinntem Chromium paketieren')
        full = input('Auswahl [1]: ').strip() == '2'
        if full:
            accepted = input('Fertige Chromium-/Drittanbieter-Binaerpakete aus GitHub herunterladen? [j/N]: ').strip().lower() in ('j', 'ja', 'y', 'yes')
    if full and args.action not in ('install', 'update'):
        raise ValueError('--build-browser nur fuer Install/Update oder Plan.')
    with common.operation(base, args.action, tool='Enki_Browser_Study'):
        if full:
            preflight(base, accepted)
        if args.action == 'uninstall':
            if (base / 'development').exists() or (base / 'package-build.json').exists():
                raise ValueError('Entwicklungs-/Paketdaten vorhanden; zuerst sichern/pruefen, nichts loeschen.')
            if runtime.exists() or marker.exists():
                common.validate(runtime, marker, SPEC, full=True)
                shutil.rmtree(common.checked(runtime))
                marker.unlink()
            print('Unveraenderte Studienquellen entfernt; Profile, Entwicklungsdaten und Logs bleiben.')
        else:
            common.install(runtime, marker, base, SPEC)
            if full:
                build(base, runtime, marker, accepted)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError, EOFError) as error:
        print('Enki_Browser_Study fehlgeschlagen/abgebrochen:', error, file=sys.stderr)
        print('Vorhandene Studien-/Entwicklungsdaten bleiben erhalten.', file=sys.stderr)
        sys.exit(1)
