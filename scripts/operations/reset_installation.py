#!/usr/bin/env python3
"""Review and archive stale installer locks; never kill processes or remove data."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import sys
import uuid

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts/lib'))
from install_rollback import inspect_lock, safe
from installation_maintenance import maintenance_guard

BUILDERS = {'cargo', 'rustc', 'go', 'cc1', 'cc1plus', 'gcc', 'g++', 'clang', 'clang++', 'cmake', 'make', 'maturin'}
PACKAGES = {'apt', 'apt-get', 'dpkg', 'unattended-upgr'}


def scan_processes(root, proc=Path('/proc')):
    if not (proc / 'self/status').is_file():
        raise ValueError('Linux-/proc nicht verfuegbar; kein Reset freigegeben.')
    found, unreadable = [], []
    for directory in proc.iterdir():
        if not directory.name.isdecimal() or int(directory.name) == os.getpid():
            continue
        try:
            uid = directory.stat().st_uid
            name = (directory / 'comm').read_text().strip()
            if name in PACKAGES:
                found.append({'pid': int(directory.name), 'name': name, 'reason': 'package-manager'})
                continue
            if uid != os.geteuid():
                continue
            command = (directory / 'cmdline').read_bytes().replace(b'\0', b' ').decode('utf-8', errors='replace')
            markers = ('install_rollback.py', '/scripts/tools/', str(root / 'tools') + '/', '/native-github/', '/_build/')
            if name in BUILDERS or any(marker in command for marker in markers):
                found.append({'pid': int(directory.name), 'name': name, 'reason': 'installer-or-build'})
        except FileNotFoundError:
            continue  # A process exited while taking the snapshot.
        except OSError:
            unreadable.append(int(directory.name))
    return {'active': found, 'unreadable': unreadable}


def targets(root, tool=None):
    result = [('global', safe(root / 'install_transactions/.runner-lock'))]
    if tool:
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        allowed = {item['id'] for item in entries}
        if not re.fullmatch(r'[a-z][a-z0-9_]{0,79}', tool) or tool not in allowed:
            raise ValueError('Unbekannte Tool-ID; Registry-Slug wie cadvisor oder node_red verwenden.')
        result.append((tool, safe(root / 'tools' / tool / 'operation.lock')))
    return result


def snapshot(path, global_lock=False):
    safe(path)
    if not path.exists():
        return None
    info = path.lstat()
    if not stat.S_ISDIR(info.st_mode) or path.is_mount() or info.st_uid != os.geteuid():
        raise ValueError('Sperre ist kein eigener regulaerer Ordner; nichts freigegeben.')
    names = {entry.name for entry in path.iterdir()}
    if names - ({'owner.json'} if global_lock else set()):
        raise ValueError('Unbekannter Inhalt im Sperrordner; keine automatische Archivierung.')
    digest = None
    if 'owner.json' in names:
        owner = safe(path / 'owner.json')
        metadata = owner.lstat()
        if not stat.S_ISREG(metadata.st_mode) or metadata.st_nlink != 1 or metadata.st_size > 16384:
            raise ValueError('Unsichere Besitzerdatei; keine Archivierung.')
        digest = hashlib.sha256(owner.read_bytes()).hexdigest()
    return {'device': info.st_dev, 'inode': info.st_ino, 'owner_sha256': digest}


def review(root, tool=None):
    global_report = inspect_lock(root)
    processes = scan_processes(root)
    locks = []
    for name, path in targets(root, tool):
        locks.append({'name': name, 'path': str(path), 'snapshot': snapshot(path, name == 'global')})
    return {'global': global_report, 'processes': processes, 'locks': locks,
            'active_owner': global_report['state'] == 'owner-process-active',
            'note': 'Keine Prozesse beendet, keine Sperren oder Daten veraendert.'}


def reset(root, tool=None, confirmed=False, legacy_reviewed=False):
    if not confirmed:
        raise ValueError('--confirm-reset erforderlich; nur --check ausfuehren.')
    with maintenance_guard(root, exclusive=True):
        report = review(root, tool)
        if report['active_owner'] or report['processes']['active']:
            raise ValueError('Aktive Installation/Compiler/Paketverwaltung erkannt. Erst kontrolliert beenden oder abwarten; keine Entsperrung.')
        if report['processes']['unreadable']:
            raise ValueError('Prozesspruefung unvollstaendig; kein Reset freigegeben.')
        existing = [item for item in report['locks'] if item['snapshot'] is not None]
        if existing and not legacy_reviewed:
            raise ValueError('--acknowledge-legacy erforderlich: alle parallelen/alten Installer manuell pruefen und schliessen.')
        # Check once more while new cooperating installers are excluded by flock.
        current = scan_processes(root)
        if current['active'] or current['unreadable']:
            raise ValueError('Prozesszustand inzwischen geaendert; nichts freigegeben.')
        for item in existing:
            if snapshot(Path(item['path']), item['name'] == 'global') != item['snapshot']:
                raise ValueError('Sperre inzwischen veraendert; nichts freigegeben.')
        logs = safe(root / 'install_logs')
        logs.mkdir(parents=True, exist_ok=True, mode=0o700)
        stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '_' + uuid.uuid4().hex
        logfile = safe(logs / ('installation_reset_' + stamp + '.log'))
        with logfile.open('x', encoding='utf-8') as log:
            logfile.chmod(0o600)
            def record(event, **values):
                log.write(json.dumps({'event': event, **values}) + '\n')
                log.flush()
                os.fsync(log.fileno())
            record('reset-start', tool=tool, locks=len(existing))
            print('Installations-Reset Log:', logfile, flush=True)
            try:
                archive = safe(root / 'install_transactions/reset_archives' / stamp)
                if existing:
                    archive.mkdir(parents=True, mode=0o700)
                for item in existing:
                    source = safe(Path(item['path']))
                    if snapshot(source, item['name'] == 'global') != item['snapshot']:
                        raise ValueError('Sperre vor Archivierung veraendert; Reset stoppen.')
                    destination = safe(archive / (item['name'] + '.lock'))
                    if destination.exists():
                        raise ValueError('Archivziel belegt; nichts ueberschreiben.')
                    record('archive-planned', source=str(source), destination=str(destination))
                    source.rename(destination)
                    record('archived', source=str(source), destination=str(destination))
                record('success', archived=len(existing), data_removed=False)
            except BaseException:
                record('failed-or-interrupted', partial_archive_possible=True)
                raise
        print('Reset abgeschlossen: ' + str(len(existing)) + ' Sperren archiviert. Keine Tooldateien, Modelle oder Nutzerdaten geloescht.')
        return logfile


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--check', action='store_true')
    modes.add_argument('--apply', action='store_true')
    parser.add_argument('--tool', help='Optional registry slug, e.g. node_red')
    parser.add_argument('--confirm-reset', action='store_true')
    parser.add_argument('--acknowledge-legacy', action='store_true')
    args = parser.parse_args(argv)
    try:
        root = safe(Path(os.environ.get('OPENCLAW_USER_DATA_DIR') or str(Path.home() / '.openclaw_ultimate_user_data')))
        if root == Path(root.anchor):
            raise ValueError('Workspace darf keine Dateisystemwurzel sein.')
        if args.apply:
            reset(root, args.tool, args.confirm_reset, args.acknowledge_legacy)
        else:
            print(json.dumps(review(root, args.tool), indent=2))
        return 0
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('Installations-Reset blockiert: ' + str(error), file=sys.stderr)
        if args.apply and args.confirm_reset and 'root' in locals():
            try:
                directory = safe(root / 'install_logs')
                directory.mkdir(parents=True, exist_ok=True, mode=0o700)
                failed = safe(directory / ('installation_reset_failed_' + uuid.uuid4().hex + '.log'))
                with failed.open('x', encoding='utf-8') as stream:
                    failed.chmod(0o600)
                    json.dump({'event': 'blocked-or-failed', 'message': str(error),
                               'tool': args.tool, 'data_removed': False}, stream)
                print('Aktuelles Reset-Fehlerprotokoll:', failed, file=sys.stderr)
            except (OSError, ValueError):
                print('Reset-Fehlerprotokoll nicht sicher schreibbar; keine alte Logdatei als aktuell ausgeben.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
