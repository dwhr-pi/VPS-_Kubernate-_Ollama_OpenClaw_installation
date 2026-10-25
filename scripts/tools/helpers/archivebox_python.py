"""Select ArchiveBox's interpreter without changing the host Python or PATH."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

import gap_tools as common
import native_uv


def probe(python, base, env, recipe):
    lower = tuple(recipe['python_min'])
    upper = tuple(recipe.get('python_max', [99]))
    return common.run([str(python), '-I', '-B', '-c',
                       'import sys,ssl,venv; assert ' + repr(lower) +
                       ' <= sys.version_info[:3] < ' + repr(upper) +
                       '; print(sys.executable)'], base, env).strip()


def select(base, spec, approved=False, allow_download=False):
    recipe = spec['recipe']
    env = {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')}
    env.update(UV_NO_CONFIG='1', UV_PYTHON_DOWNLOADS='never', PYTHONDONTWRITEBYTECODE='1')
    explicit = os.environ.get('NATIVE_SOURCE_PYTHON_BIN')
    if explicit:
        try:
            probe(explicit, base, env, recipe)
        except (OSError, subprocess.SubprocessError) as error:
            raise ValueError('ArchiveBox: explizites NATIVE_SOURCE_PYTHON_BIN braucht Python >=3.13 mit SSL/venv; keine automatische Ersetzung.') from error
        return explicit
    for candidate in (shutil.which('python3.13'), shutil.which('python3.14'), sys.executable):
        if not candidate:
            continue
        try:
            probe(candidate, base, env, recipe)
        except (OSError, subprocess.SubprocessError):
            continue
        print('ArchiveBox: passendes vorhandenes Python:', candidate)
        return candidate

    slot = common.checked(base / 'toolchain/archivebox-python313')
    marker = common.checked(slot / 'python-ready.json')
    if slot.exists():
        record = json.loads(marker.read_text(encoding='utf-8'))
        relative = Path(record['entry'])
        if relative.is_absolute() or '..' in relative.parts or '\\' in record['entry'] or ':' in record['entry']:
            raise ValueError('ArchiveBox: ungueltiger privater Python-Pfad.')
        files = common.inventory(slot)
        files.pop('python-ready.json', None)
        if files != record['files']:
            raise ValueError('ArchiveBox: private Python-Dateien veraendert; nichts ueberschreiben.')
        python = slot / relative
        if not python.resolve().is_relative_to(slot.resolve()):
            raise ValueError('ArchiveBox: privates Python verlaesst Toolchain-Verzeichnis.')
        probe(python, base, env, recipe)
        return str(python)

    print('ArchiveBox: Python >=3.13 fehlt; der ausgewaehlte System-Interpreter ist nicht geeignet.')
    if allow_download and not approved and sys.stdin.isatty():
        print('Privates Python 3.13 via uv/GitHub bereitstellen? [j/N]', flush=True)
        print('Warte auf Ihre Eingabe und Enter. Nur [j/ja/y/yes] erlaubt die Aktion; Nur [Enter] bedeutet: Nein.', flush=True)
        try:
            approved = input().strip().lower() in ('j', 'ja', 'y', 'yes')
        except EOFError:
            approved = False
    if not allow_download or not approved:
        raise ValueError('ArchiveBox: Python >=3.13 erforderlich. NATIVE_SOURCE_PYTHON_BIN setzen oder bash scripts/tools/archivebox_install.sh --install-build-deps bewusst freigeben; kein System-Python ersetzt.')

    common.reserve(base, {'reserve_mb': recipe['disk_mb'] + 1024})
    uv = native_uv.select(base, spec, approved=True, allow_download=True)
    slot.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Keep the final path stable: venvs later reference this interpreter.
    slot.mkdir(mode=0o700)
    env.update(UV_PYTHON_INSTALL_DIR=str(slot / 'managed'), UV_CACHE_DIR=str(slot / 'cache'),
               UV_PYTHON_DOWNLOADS='manual')
    try:
        print('ArchiveBox: private Python-3.13-Laufzeit aus Astral python-build-standalone via uv; kein globaler PATH/Launcher.')
        common.run([uv, 'python', 'install', '3.13', '--no-bin', '--no-config'], base, env)
        python = Path(common.run([uv, 'python', 'find', '3.13', '--managed-python',
                                  '--no-python-downloads', '--no-config'], base, env).strip())
        if not python.is_absolute() or not python.is_file() or not python.resolve().is_relative_to((slot / 'managed').resolve()):
            raise ValueError('ArchiveBox: uv lieferte keinen privaten Python-Pfad.')
        probe(python, base, env, recipe)
        marker.write_text(json.dumps({'entry': python.relative_to(slot).as_posix(),
                                      'files': common.inventory(slot)}), encoding='utf-8')
    except BaseException:
        # Only the directory created by this invocation is eligible for cleanup.
        shutil.rmtree(common.checked(slot))
        raise
    print('ArchiveBox: privates Python bereit; Toolchain bleibt bei App-Deinstallation erhalten.')
    return str(python)
