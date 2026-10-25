#!/usr/bin/env python3
"""Portable status inventory, never a credential or executable-marker backup."""
import argparse
from datetime import datetime, timezone
import hashlib
import hmac
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import stat
import sys
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts/lib'))
from install_rollback import safe
from installation_maintenance import maintenance_guard

STATUS_FILES = ('installed_tools.txt', 'status/installed_tools.txt')
PROFILE_FILES = ('installed_profiles.txt', 'status/installed_profiles.txt')
FORMAT = 'openclaw-installation-inventory'


def canonical(value):
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(',', ':')).encode('utf-8')


def registry():
    setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
    tools, profiles = set(), set()
    for key, target in (('TOOL_KEYS', tools), ('PROFILE_KEYS', profiles)):
        for match in re.findall(r'^' + key + r'\+?=\(([^\n]*)\)', setup, re.M):
            target.update(shlex.split(match))
    profiles.update(re.findall(r'^PROFILES\["([^"\n]+)"\]=', setup, re.M))
    items = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
    lookup = {name.lower().replace('-', '_'): name for name in tools}
    specs = {}
    for item in items:
        name = lookup.get(item['name'].lower().replace('-', '_'), item['name'])
        tools.add(name)
        specs[name] = item
    return tools, profiles, specs


def read_text(path):
    safe(path)
    if not path.exists():
        return ''
    info = path.lstat()
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_size > 1024**2:
        raise ValueError('Statusdatei nicht regulaer, mehrfach verlinkt oder zu gross.')
    return path.read_text(encoding='utf-8')


def marker_hint(path, spec):
    """Validate local artifact references without executing a tool or importing a marker."""
    try:
        if path.stat().st_size > 8 * 1024**2:
            return 'unverified'
        record = json.loads(path.read_text(encoding='utf-8'))
        files = record.get('files', record.get('hashes', {}))
        entries = record.get('artifacts', record.get('entries', []))
        if not entries and record.get('entry'):
            entries = [record['entry']]
        if not isinstance(files, dict) or not isinstance(entries, list) or not entries or len(entries) > 256:
            return 'unverified'
        if spec.get('source_commit') and record.get('commit', record.get('pin')) != spec['source_commit']:
            return 'unverified'
        for entry in entries:
            relative = Path(entry)
            if relative.is_absolute() or '..' in relative.parts or '\\' in entry or ':' in entry:
                return 'unverified'
            artifact = path.parent / relative
            if any(parent.is_symlink() or (hasattr(parent, 'is_junction') and parent.is_junction())
                   for parent in (artifact, *artifact.parents)):
                return 'unverified'
            if not artifact.is_file() or artifact.stat().st_size > 2 * 1024**3:
                return 'unverified'
            expected = files.get(entry)
            if not isinstance(expected, str) or not re.fullmatch(r'[0-9a-f]{64}', expected):
                return 'unverified'
            digest = hashlib.sha256()
            with artifact.open('rb') as stream:
                for chunk in iter(lambda: stream.read(1024**2), b''):
                    digest.update(chunk)
            if digest.hexdigest() != expected:
                return 'unverified'
        return 'artifact-hashes-match'
    except (OSError, ValueError, TypeError, AttributeError, KeyError):
        return 'unverified'


def evidence(name, root, specs):
    spec = specs.get(name, {})
    value = spec.get('check_value', '')
    if spec.get('check_type') == 'path' and value:
        if value.startswith('~/.openclaw_ultimate_user_data/'):
            path = root / value[len('~/.openclaw_ultimate_user_data/'):]
        elif value.startswith('/'):
            path = Path(value)
        else:
            return 'unverified'
        try:
            # Do not execute check/doctor scripts or restore marker contents.
            for parent in (path, *path.parents):
                if parent.is_symlink() or (hasattr(parent, 'is_junction') and parent.is_junction()):
                    return 'unverified'
            if path.is_dir():
                return 'directory-present'
            if path.is_file() and path.stat().st_size > 0:
                if path.suffix == '.json' and path.is_relative_to(root / 'tools'):
                    return marker_hint(path, spec)
                return 'file-present'
        except OSError:
            pass
    if spec.get('check_type') == 'command' and re.fullmatch(r'[A-Za-z0-9_.+-]+', value):
        # A generic interpreter alone does not prove that an application exists.
        if value not in {'python', 'python3', 'node', 'npm', 'bash', 'sh', 'pip', 'pip3'} and shutil.which(value):
            return 'command-present'
    if name == 'Ollama' and shutil.which('ollama'):
        return 'command-present'
    return 'unverified'


def snapshot(root):
    known, known_profiles, specs = registry()
    saved, saved_profiles, ignored = set(), set(), 0
    for files, allowed, output in ((STATUS_FILES, known, saved), (PROFILE_FILES, known_profiles, saved_profiles)):
        for relative in files:
            for line in read_text(root / relative).splitlines():
                name = line.strip().strip('"')
                if name in allowed:
                    output.add(name)
                elif name:
                    ignored += 1
    # Recover registered filesystem evidence even if a status copy was lost.
    local = {name: evidence(name, root, specs) for name in known}
    names = sorted(saved | {name for name, state in local.items() if state != 'unverified'}, key=str.casefold)
    return {'created_utc': datetime.now(timezone.utc).isoformat(),
            'registry_sha256': hashlib.sha256((ROOT / 'config/tools.yml').read_bytes()).hexdigest(),
            'tools': [{'name': name, 'recorded': name in saved, 'evidence_at_export': local[name]} for name in names],
            'recorded_profiles': sorted(saved_profiles), 'ignored_status_lines': ignored,
            'runtime_verified': False}


def write_new(path, text):
    safe(path)
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    with path.open('x', encoding='utf-8', newline='\n') as stream:
        path.chmod(0o600)
        stream.write(text)
        stream.flush()
        os.fsync(stream.fileno())


def export(root, output, allow_workspace=False):
    safe(output)
    if output.suffix.lower() != '.json' or (output.is_relative_to(root) and not allow_workspace):
        raise ValueError('Externen absoluten JSON-Zielpfad ausserhalb des Workspace waehlen.')
    summary = output.with_suffix('.md')
    if output.exists() or summary.exists():
        raise ValueError('Exportziel bereits vorhanden; nichts ueberschreiben.')
    with maintenance_guard(root, exclusive=True):
        payload = snapshot(root)
        bundle = {'format': FORMAT, 'version': 1, 'payload': payload,
                  'sha256': hashlib.sha256(canonical(payload)).hexdigest()}
        lines = ['# Erfasste Setup-Programme', '', 'Stand UTC: ' + payload['created_utc'], '',
                 'Keine Runtime-Abnahme; Status-/Nachweisbestand zum Exportzeitpunkt.', '',
                 '| Programm | Status erfasst | Lokaler Hinweis |', '|---|---|---|']
        for item in payload['tools']:
            lines.append('| ' + item['name'] + ' | ' + ('ja' if item['recorded'] else 'nein') + ' | ' + item['evidence_at_export'] + ' |')
        lines.extend(['', 'Erfasste Profile: ' + ', '.join(payload['recorded_profiles']), '',
                      'Dieser Export enthaelt keine Programme, Modelle, API-Keys oder vollstaendigen Logs.'])
        write_new(summary, '\n'.join(lines) + '\n')
        write_new(output, json.dumps(bundle, indent=2, ensure_ascii=False) + '\n')
    print('Installationsinventar exportiert:', output)
    print('Lesbare Programmliste:', summary)
    print('Extern aufbewahren. SHA256 prueft Beschaedigung, nicht die Echtheit des Absenders.')
    return bundle


def load(path):
    safe(path)
    if not path.is_file() or path.stat().st_size > 8 * 1024**2:
        raise ValueError('Exportdatei fehlt oder ist zu gross.')
    bundle = json.loads(path.read_text(encoding='utf-8'))
    if bundle.get('format') != FORMAT or bundle.get('version') != 1:
        raise ValueError('Unbekanntes Exportformat.')
    data = bundle['payload']
    if not hmac.compare_digest(hashlib.sha256(canonical(data)).hexdigest(), bundle.get('sha256', '')):
        raise ValueError('Pruefsumme stimmt nicht; keine Wiederherstellung.')
    if not isinstance(data.get('tools'), list) or len(data['tools']) > 2000 or not isinstance(data.get('recorded_profiles'), list):
        raise ValueError('Ungueltige Inventarliste.')
    names = [item['name'] for item in data['tools']] + data['recorded_profiles']
    if len(names) > 3000 or any(not isinstance(name, str) or not re.fullmatch(r'[\w.+-]{1,128}', name) for name in names):
        raise ValueError('Ungueltige Statusnamen.')
    return data


def preview(root, data):
    known, profiles, specs = registry()
    ready, pending = [], []
    for name in sorted({item['name'] for item in data['tools']}, key=str.casefold):
        hint = evidence(name, root, specs) if name in known else 'unknown-tool'
        # Bare directories are not a complete installation proof.
        if hint in ('artifact-hashes-match', 'command-present'):
            ready.append({'name': name, 'evidence_now': hint})
        else:
            pending.append({'name': name, 'reason': hint})
    return {'restore_candidates': ready, 'pending_tools': pending,
            'recorded_profiles': data['recorded_profiles'], 'profiles_restored': False,
            'runtime_verified': False}


def replace_text(path, text):
    safe(path)
    read_text(path)  # Reject unsafe existing files before replacement.
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, temporary = tempfile.mkstemp(prefix='.status-import-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


def restore(root, data, confirmed=False):
    if not confirmed:
        raise ValueError('--confirm-restore erforderlich; zuerst Vorschau lesen.')
    with maintenance_guard(root, exclusive=True):
        report = preview(root, data)
        additions = {item['name'] for item in report['restore_candidates']}
        paths = [safe(root / relative) for relative in STATUS_FILES]
        before = {str(path): read_text(path) for path in paths}
        existing = set(line for text in before.values() for line in text.splitlines() if line)
        merged = '\n'.join(sorted(existing | additions, key=str.casefold)) + ('\n' if existing or additions else '')
        if len(merged.encode('utf-8')) > 1024**2:
            raise ValueError('Zusammengefuehrter Status zu gross; vorhandene Dateien bleiben unveraendert.')
        stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '_' + uuid.uuid4().hex
        history = safe(root / 'status_restore_history' / stamp)
        history.mkdir(parents=True, mode=0o700)
        for index, path in enumerate(paths):
            write_new(history / ('before_' + str(index) + '.txt'), before[str(path)])
        write_new(history / 'imported_inventory.json', json.dumps(data, indent=2, ensure_ascii=False))
        journal = history / 'result.json'
        write_new(journal, json.dumps({'state': 'preparing', **report}, indent=2))
        try:
            for path in paths:
                replace_text(path, merged)
            replace_text(journal, json.dumps({'state': 'success', **report}, indent=2))
        except BaseException:
            replace_text(journal, json.dumps({'state': 'failed-partial-restore-possible', **report}, indent=2))
            raise
    print(json.dumps(report, indent=2, ensure_ascii=False))
    print('Statuskopien zusammengefuehrt. Vorheriger Stand und offene Eintraege:', history)
    print('Keine Programme/Marker erzeugt. Profile bleiben historisch erfasst, nicht automatisch installiert.')
    return report


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('list', 'export', 'preview', 'restore'))
    parser.add_argument('--output', type=Path)
    parser.add_argument('--input', type=Path)
    parser.add_argument('--allow-workspace', action='store_true', help='Internal backup snapshot only, not an independent export')
    parser.add_argument('--confirm-restore', action='store_true')
    args = parser.parse_args(argv)
    try:
        root = safe(Path(os.environ.get('OPENCLAW_USER_DATA_DIR') or str(Path.home() / '.openclaw_ultimate_user_data')))
        if root == Path(root.anchor):
            raise ValueError('Workspace darf keine Dateisystemwurzel sein.')
        if args.action == 'list':
            print(json.dumps(snapshot(root), indent=2, ensure_ascii=False))
        elif args.action == 'export':
            if args.output is None:
                raise ValueError('--output ABSOLUT.json erforderlich.')
            export(root, args.output, args.allow_workspace)
        else:
            if args.input is None:
                raise ValueError('--input ABSOLUT.json erforderlich.')
            data = load(args.input)
            if args.action == 'preview':
                print(json.dumps(preview(root, data), indent=2, ensure_ascii=False))
            else:
                restore(root, data, args.confirm_restore)
        return 0
    except (OSError, ValueError, KeyError, TypeError, AttributeError) as error:
        print('Installationsinventar fehlgeschlagen: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
