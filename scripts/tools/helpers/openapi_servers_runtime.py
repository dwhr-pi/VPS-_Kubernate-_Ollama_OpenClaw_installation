"""Install only the pinned time example; configuration and start are explicit."""
import argparse
import json
import os
from pathlib import Path
import platform
import secrets
import shutil
import subprocess
import sys

import gap_tools as common
from find_skills import checked


def uv_spec():
    return {'id': 'openapi_servers', 'recipe': {'private_uv': '0.13.5', 'disk_mb': 2048}}


def python_binary():
    return os.environ.get('OPENAPI_SERVERS_PYTHON_BIN') or common.executable('python3')


def prepare(base, approved=False):
    if platform.system() != 'Linux':
        raise ValueError('OpenAPI_Servers: Zeitserver-Umgebung nur fuer Linux/WSL, kein Windows-Crossbuild.')
    env = {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')}
    common.run([python_binary(), '-I', '-c', 'import sys,ssl; assert sys.version_info >= (3,10)'], base, env)
    import native_uv
    native_uv.prepare(base, uv_spec(), approved=approved)


def build(runtime, env):
    import native_uv
    uv = native_uv.select(runtime.parent, uv_spec())
    env.update(UV_NO_CONFIG='1', UV_PYTHON_DOWNLOADS='never', UV_ONLY_BINARY=':all:')
    requirements = checked(runtime / 'servers/time/requirements.txt')
    if not requirements.is_file() or not checked(runtime / 'servers/time/main.py').is_file():
        raise ValueError('Gepinnter Zeitserver unvollstaendig; keine Ersatzquelle.')
    lock = runtime / 'time-requirements.lock'
    python = python_binary()
    print('Zeitserver: lokal aufgeloeste, gehashte Wheel-Abhaengigkeiten; kein upstream-vollstaendig gepinnter Lock.', flush=True)
    common.run([uv, 'pip', 'compile', requirements, '--python', python,
                '--only-binary', ':all:', '--generate-hashes', '--output-file', lock], runtime, env)
    common.run([uv, 'venv', '--no-python-downloads', '--python', python, runtime / '.venv'], runtime, env)
    vpython = runtime / '.venv/bin/python'
    common.run([uv, 'pip', 'sync', lock, '--python', vpython,
                '--require-hashes', '--only-binary', ':all:'], runtime, env)
    common.run([vpython, '-I', '-c', 'import fastapi,uvicorn,pytz,dateutil; print(fastapi.__version__)'], runtime, env)
    shutil.copyfile(Path(__file__).with_name('openapi_time_guard.py'), runtime / 'openapi_time_guard.py')
    print('Zeitserver-Umgebung vorbereitet. Noch kein API-Key, Dienst, Listener oder WebUI-Eintrag eingerichtet.')
    return ['servers/time/main.py', 'servers/time/requirements.txt', 'LICENSE',
            'time-requirements.lock', '.venv/pyvenv.cfg', 'openapi_time_guard.py']


def configure(base, port=8021, origins=()):
    from openapi_time_guard import validate_config
    folder = checked(base / 'config')
    folder.mkdir(mode=0o700, exist_ok=True)
    path = checked(folder / 'time.json')
    if path.exists():
        print('Vorhandene Konfiguration bleibt unveraendert:', path)
        return path
    config = {'version': 1, 'port': port, 'bearer_token': secrets.token_urlsafe(32), 'allowed_origins': list(origins)}
    validate_config(config)
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, 'w', encoding='utf-8') as stream:
        json.dump(config, stream, indent=2)
        stream.write('\n')
    print('Private Zeitserver-Konfiguration angelegt:', path)
    print('Schluessel nur bewusst mit openapi_servers_configure.sh show-key anzeigen; kein Server gestartet.')
    return path


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('configure', 'show-key', 'start', 'plan'))
    parser.add_argument('--port', type=int, default=8021)
    parser.add_argument('--origin', action='append', default=[])
    opts = parser.parse_args(argv)
    if opts.action != 'configure' and (opts.port != 8021 or opts.origin):
        parser.error('--port/--origin nur fuer configure; Bestand manuell pruefen, kein stilles Umschreiben.')
    base, runtime, marker = common.paths('openapi_servers')
    if opts.action == 'plan':
        print('Zeitserver: nur 127.0.0.1, Port 8021, Bearer-Pflicht; Konfiguration:', base / 'config/time.json')
        print('Kein Schreiben, Download, Import eines Upstream-Servers oder Start.')
        return 0
    common.validate(runtime, marker, common.SPECS['openapi_servers'], full=True)
    if opts.action == 'configure':
        configure(base, opts.port, opts.origin)
        return 0
    from openapi_time_guard import load_config
    config = load_config(checked(base / 'config/time.json'))
    if opts.action == 'show-key':
        print(config['bearer_token'])
        return 0
    vpython = runtime / '.venv/bin/python'
    if not vpython.is_file():
        raise ValueError('Private Python-Laufzeit fehlt; kein System-Python-Fallback beim Start.')
    env = {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')}
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    print('Bewusster Vordergrundstart: Zeitserver auf 127.0.0.1:' + str(config['port']) + '; Beenden mit Strg+C.', flush=True)
    os.execve(str(vpython), [str(vpython), '-I', '-B', str(runtime / 'openapi_time_guard.py')], env)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print('OpenAPI-Sicherheit/Einrichtung fehlgeschlagen:', error, file=sys.stderr)
        sys.exit(1)
