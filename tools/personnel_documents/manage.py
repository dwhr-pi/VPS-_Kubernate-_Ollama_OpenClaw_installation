"""Install a private launcher for this GitHub checkout; no downloads or packages."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile

REPO = Path(__file__).resolve().parents[2]
SOURCE = REPO / 'tools/personnel_documents/pipeline.py'


def safe_path(path):
    path = Path(path).expanduser()
    if not path.is_absolute() or path != path.resolve():
        raise ValueError('Absoluter normalisierter Pfad ohne Symlinks erforderlich.')
    return path


def paths():
    root = safe_path(os.environ.get('OPENCLAW_USER_DATA_DIR') or
                     Path.home() / '.openclaw_ultimate_user_data')
    if root == Path(root.anchor) or root.is_relative_to(REPO):
        raise ValueError('User-Workspace muss ausserhalb des Setup-Repositories liegen.')
    base = safe_path(root / 'tools/personnel_documents')
    if os.name == 'posix':
        for directory in (root, base.parent, base, base / 'bin', root / 'install_logs'):
            if directory.exists() and directory.stat().st_mode & 0o022:
                raise ValueError('User-/Tool-/Logverzeichnis ist fuer Gruppe/Andere schreibbar; Rechte zuerst pruefen.')
    for child in ('bin', 'bin/personnel-documents-ai', 'installed.json', 'operation.lock'):
        safe_path(base / child)
    safe_path(root / 'install_logs')
    return root, base


FIXTURE = REPO / 'examples/personnel_documents/proposal.json'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def launcher_text(source, checksum, fixture_checksum):
    return f'''#!/usr/bin/env -S python3 -I -B
import hashlib
from pathlib import Path
import runpy
import sys
source = Path({str(source)!r})
fixture = Path({str(FIXTURE)!r})
if sys.version_info < (3, 10):
    sys.exit('Personnel Documents AI: Python 3.10+ erforderlich.')
if not source.is_file() or source.is_symlink() or hashlib.sha256(source.read_bytes()).hexdigest() != {checksum!r}:
    sys.exit('Personnel Documents AI: Setup-Quelle fehlt/ist geaendert. Im aktuellen Setup personnel_documents_update.sh ausfuehren.')
if not fixture.is_file() or fixture.is_symlink() or hashlib.sha256(fixture.read_bytes()).hexdigest() != {fixture_checksum!r}:
    sys.exit('Personalakten: synthetische Pruefdatei fehlt/ist geaendert; Starter aktualisieren.')
sys.argv[0] = str(source)
runpy.run_path(str(source), run_name='__main__')
'''


def atomic_write(path, content, mode=0o600):
    safe_path(path)
    fd, temp = tempfile.mkstemp(prefix='.personnel-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='\n') as stream:
            stream.write(content)
        os.chmod(temp, mode)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def installed(base):
    marker, launcher = base / 'installed.json', base / 'bin/personnel-documents-ai'
    try:
        safe_path(SOURCE)
        safe_path(FIXTURE)
        safe_path(marker)
        safe_path(launcher)
        record = json.loads(marker.read_text(encoding='utf-8'))
        source = Path(record['source'])
        return (source == SOURCE and record['sha256'] == digest(SOURCE) and record['fixture_sha256'] == digest(FIXTURE)
                and (os.name != 'posix' or os.access(launcher, os.X_OK))
                and record.get('tool') == 'Personnel_Documents_AI'
                and launcher.read_text(encoding='utf-8') == launcher_text(SOURCE, record['sha256'], record['fixture_sha256']))
    except (OSError, ValueError, KeyError, TypeError):
        return False


def preflight(base):
    safe_path(SOURCE)
    safe_path(FIXTURE)
    current = base
    while not current.exists():
        current = current.parent
    if shutil.disk_usage(current).free < 64 * 1024 * 1024:
        raise ValueError('Mindestens 64 MiB freier Ziel-Speicher erforderlich.')
    proc = Path('/proc/version')
    if proc.exists() and 'microsoft' in proc.read_text().lower() and Path('/mnt/c').is_dir():
        if shutil.disk_usage('/mnt/c').free < 1024 * 1024 * 1024:
            raise ValueError('WSL: mindestens 1 GiB freie Windows-C:-Reserve erforderlich.')
    compile(SOURCE.read_text(encoding='utf-8'), str(SOURCE), 'exec')


@contextmanager
def operation(base):
    lock = base / 'operation.lock'
    try:
        lock.mkdir(mode=0o700)
    except FileExistsError as exc:
        raise ValueError('Andere Personalakten-Operation aktiv. Verwaiste operation.lock erst nach Prozesspruefung manuell entfernen.') from exc
    try:
        yield
    finally:
        lock.rmdir()


def install(base):
    launcher = base / 'bin/personnel-documents-ai'
    marker = base / 'installed.json'
    if launcher.exists() and not marker.exists():
        raise ValueError('Nicht registrierter Starter vorhanden; vor Installation manuell sichern/umbenennen.')
    # Reject foreign registrations rather than replacing an unrelated program.
    if marker.exists():
        record = json.loads(marker.read_text(encoding='utf-8'))
        if record.get('tool') != 'Personnel_Documents_AI':
            raise ValueError('Fremde Registrierung; nichts ueberschrieben.')
        if record.get('source') != str(SOURCE):
            raise ValueError('Anderer Setup-Checkout registriert; zuerst manuell pruefen.')
        if launcher.exists() and launcher.read_text(encoding='utf-8') != launcher_text(SOURCE, record['sha256'], record['fixture_sha256']):
            raise ValueError('Starter lokal geaendert; nichts ueberschrieben.')
    safe_path(SOURCE)
    checksum = digest(SOURCE)
    launcher.parent.mkdir(mode=0o700, exist_ok=True)
    atomic_write(launcher, launcher_text(SOURCE, checksum, digest(FIXTURE)), 0o700)
    atomic_write(marker, json.dumps({'tool': 'Personnel_Documents_AI', 'source': str(SOURCE),
                                   'sha256': checksum, 'fixture_sha256': digest(FIXTURE), 'source_url':
                                   'https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation'}, indent=2) + '\n')


def uninstall(base):
    marker, launcher = base / 'installed.json', base / 'bin/personnel-documents-ai'
    if not marker.exists():
        print('Keine registrierte Installation; nichts entfernt.')
        return
    record = json.loads(marker.read_text(encoding='utf-8'))
    if record.get('tool') != 'Personnel_Documents_AI':
        raise ValueError('Fremde Registrierung; nichts entfernt.')
    if record.get('source') != str(SOURCE):
        raise ValueError('Anderer Setup-Checkout registriert; zuerst manuell pruefen.')
    expected = launcher_text(SOURCE, record['sha256'], record['fixture_sha256'])
    if launcher.exists() and launcher.read_text(encoding='utf-8') != expected:
        raise ValueError('Starter lokal geaendert; vor Deinstallation manuell sichern.')
    launcher.unlink(missing_ok=True)
    marker.unlink()
    print('Starter/Registrierung entfernt. Setup-Quellen, Logs und Dokumente bleiben erhalten.')


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    aliases = {'--repair': 'update', '--dry-run': 'plan', '--plan': 'plan',
               '--status': 'status', '--check': 'check', '--uninstall': 'uninstall'}
    if argv:
        argv[0] = aliases.get(argv[0], argv[0])
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('install', 'update', 'uninstall',
                                       'plan', 'status', 'doctor', 'check'))
    args = parser.parse_args(argv)
    try:
        root, base = paths()
        if args.mode == 'plan':
            print(json.dumps({'mode': 'plan', 'installed': False, 'network': False,
                              'docker': False, 'source': str(SOURCE), 'target': str(base)}))
            return 0
        if args.mode in ('status', 'doctor', 'check'):
            ok = installed(base)
            print(json.dumps({'installed': ok, 'scope': 'github-checkout-launcher', 'network': False, 'paperless_installed': False, 'inference_tested': False}))
            return 0 if ok or args.mode == 'status' else 1
        if args.mode != 'uninstall':
            preflight(base)
        elif not base.exists():
            print('Nicht installiert; nichts entfernt.')
            return 0
        base.mkdir(parents=True, mode=0o700, exist_ok=True)
        with operation(base):
            logs = root / 'install_logs'
            logs.mkdir(parents=True, mode=0o700, exist_ok=True)
            fd, log = tempfile.mkstemp(prefix='personnel_documents_', suffix='.log', dir=logs)
            with os.fdopen(fd, 'w', encoding='utf-8') as stream:
                stream.write('Personnel-Documents-AI-Installer: 2026-10-18-github-checkout-launcher\n')
                stream.write(f'Aktion: {args.mode}\n')
                stream.write(f'Disk frei vorher: {shutil.disk_usage(base).free}\n')
                try:
                    if args.mode == 'uninstall':
                        uninstall(base)
                    elif args.mode == 'install' and installed(base):
                        print('Bereits installiert und aktuell; nichts geaendert.')
                    else:
                        install(base)
                        print(f'Installiert ohne Docker/Downloads: {base / "bin/personnel-documents-ai"}')
                    stream.write('Ergebnis: erfolgreich\n')
                    stream.write(f'Disk frei nachher: {shutil.disk_usage(base).free}\n')
                except (OSError, ValueError, KeyError, TypeError):
                    stream.write('Ergebnis: fehlgeschlagen; keine Dokumente veraendert\n')
                    raise
            print(f'Protokoll: {log}')
        return 0
    except (OSError, ValueError, KeyError, TypeError, SyntaxError) as exc:
        # Do not echo document contents or malformed manifest values.
        print('Personalakten-Installation fehlgeschlagen: Pfade, Speicher, Registrierung und Lock pruefen.', file=sys.stderr)
        if isinstance(exc, ValueError) and not isinstance(exc, json.JSONDecodeError):
            print(str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    if sys.version_info < (3, 10):
        sys.exit('Python 3.10+ erforderlich; keine Paket-/Systeminstallation.')
    raise SystemExit(main())
