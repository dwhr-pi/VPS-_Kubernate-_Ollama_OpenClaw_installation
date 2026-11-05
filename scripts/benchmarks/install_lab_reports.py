"""Portable measurement-only backups. Never restore tool installation status or secrets."""
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
import os
from pathlib import Path
import re
import stat
import tarfile
import tempfile
import uuid

MAX_BYTES = 8 * 1024 ** 2
ROOT = Path(__file__).resolve().parents[2]
STATUSES = frozenset(('passed_build_probe_uninstall', 'skipped_unsupported_contract',
                     'skipped_license_not_approved', 'skipped_insufficient_space', 'skipped_insufficient_ram',
                     'failed_install', 'failed_doctor', 'failed_probe', 'failed_cleanup',
                     'failed_process_cleanup', 'failed_supervisor', 'not_attempted_cleanup_blocked', 'refused'))


def read_bytes(path):
    path = Path(path)
    if path.is_symlink():
        raise ValueError('Linked measurement input refused')
    fd = os.open(path, os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0))
    with os.fdopen(fd, 'rb') as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_size > MAX_BYTES:
            raise ValueError('Bounded regular measurement input required')
        data = stream.read(MAX_BYTES + 1)
    if len(data) > MAX_BYTES:
        raise ValueError('Measurement input too large')
    return data


def number(value):
    if type(value) not in (int, float) or not 0 <= value <= 2 ** 53:
        raise ValueError('Finite nonnegative measurement required')
    return value


def clean_record(row):
    if not isinstance(row, dict) or not re.fullmatch(r'[a-z0-9][a-z0-9_-]{0,80}', row.get('tool', '')):
        raise ValueError('Tool identifier required')
    if row.get('status') not in STATUSES:
        raise ValueError('Completed/failed/skipped measurement status required')
    result = {'tool': row['tool'], 'status': row['status'], 'runtime_verified': False}
    if row.get('backend') in ('wsl2', 'native-linux', 'unknown'):
        result['backend'] = row['backend']
    for field in ('executed', 'cleanup_ok', 'installed_artifacts_verified', 'installed_after_cycle'):
        if field in row:
            if row[field] is not None and type(row[field]) is not bool:
                raise ValueError('Boolean or unknown measurement required')
            result[field] = row[field]
    for field, length in (('pin', 40), ('source_commit', 40), ('recipe_sha256', 64)):
        if row.get(field) is not None:
            if not re.fullmatch('[a-f0-9]{' + str(length) + '}', row[field]):
                raise ValueError('Invalid source digest')
            result[field] = row[field]
    for field in ('installed_tree_allocated_mib', 'data_with_build_caches_mib',
                  'observed_peak_disk_delta_mib', 'host_free_mib_before', 'linux_free_mib_after',
                  'cleanup_data_seconds', 'total_cycle_seconds'):
        if field in row:
            result[field] = number(row[field])
    phases = row.get('phases', {})
    if not isinstance(phases, dict) or set(phases) - {'install', 'doctor', 'probe', 'uninstall'}:
        raise ValueError('Unknown measurement phase')
    result['phases'] = {}
    for name, phase in phases.items():
        if not isinstance(phase, dict):
            raise ValueError('Measurement phase object required')
        code = phase.get('returncode')
        if type(code) is not int or not -1024 <= code <= 65535:
            raise ValueError('Real bounded process exit code required')
        result['phases'][name] = {'returncode': code, 'seconds': number(phase['seconds']),
                                'observed_peak_disk_delta_mib': number(phase['observed_peak_disk_delta_mib'])}
    # Never copy raw logs, command output, prompts, environment, credentials or local paths.
    if result['status'] == 'passed_build_probe_uninstall':
        if (result.get('executed') is not True or result.get('cleanup_ok') is not True or
                result.get('installed_artifacts_verified') is not True or
                result.get('installed_after_cycle') is not False or len(phases) != 4 or
                any(p['returncode'] != 0 for p in result['phases'].values())):
            raise ValueError('Success needs the complete verified lifecycle')
    return result


def payload(path):
    path = Path(path)
    raw = read_bytes(path)
    recorded = datetime.now(timezone.utc).isoformat()
    if path.suffix == '.tar':
        with tarfile.open(fileobj=io.BytesIO(raw), mode='r:') as archive:
            members = archive.getmembers()
            if len(members) != 2 or {m.name for m in members} != {'measurements.json', 'manifest.json'}:
                raise ValueError('Measurement-only archive required')
            if any(not m.isfile() or m.size > MAX_BYTES for m in members):
                raise ValueError('Unsafe measurement archive')
            data = archive.extractfile('measurements.json').read(MAX_BYTES + 1)
            manifest = json.loads(archive.extractfile('manifest.json').read(MAX_BYTES + 1))
            if manifest != {'schema': 1, 'sha256': hashlib.sha256(data).hexdigest()}:
                raise ValueError('Measurement checksum mismatch')
        value = json.loads(data)
        rows = value['records']
        complete = value.get('batch_complete')
    elif path.suffix == '.jsonl':
        rows = [json.loads(line) for line in raw.decode('utf-8-sig').splitlines() if line.strip()]
        complete = False if path.with_name('CYCLE_INCOMPLETE').exists() else None
    else:
        value = json.loads(raw.decode('utf-8-sig'))
        rows = value['records']
        complete = value.get('batch_complete')
    if path.suffix != '.jsonl' and value.get('recorded_utc') is not None:
        stamp = value['recorded_utc']
        if not isinstance(stamp, str) or len(stamp) > 80:
            raise ValueError('Bounded UTC timestamp required')
        parsed = datetime.fromisoformat(stamp)
        if parsed.tzinfo is None:
            raise ValueError('UTC timestamp requires timezone')
        recorded = parsed.astimezone(timezone.utc).isoformat()
    if not isinstance(rows, list) or len(rows) > 10000:
        raise ValueError('Bounded measurement records required')
    if complete is not None and type(complete) is not bool:
        raise ValueError('Completion must be explicit or unknown')
    return {'schema': 1, 'kind': 'install-lab-measurements-not-installation-status', 'batch_complete': complete,
            'recorded_utc': recorded,
            'records': [clean_record(row) for row in rows]}


def create_new(path, data):
    path = Path(path)
    fd, temporary = tempfile.mkstemp(prefix=path.name + '.pending-', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        # Atomic publication without replacing an existing file. No partial backup gets a final name.
        os.link(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


def backup_report(source, output, batch_complete=None):
    value = payload(source)
    if batch_complete is not None:
        value['batch_complete'] = batch_complete
    data = json.dumps(value, sort_keys=True, allow_nan=False).encode('utf-8')
    manifest = json.dumps({'schema': 1, 'sha256': hashlib.sha256(data).hexdigest()}).encode()
    target = io.BytesIO()
    with tarfile.open(fileobj=target, mode='w') as archive:
        for name, content in (('measurements.json', data), ('manifest.json', manifest)):
            info = tarfile.TarInfo(name)
            info.size, info.mode = len(content), 0o600
            archive.addfile(info, io.BytesIO(content))
    create_new(output, target.getvalue())


def import_report(source, workspace):
    raw = Path(workspace)
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError('Explicit external workspace required')
    for part in (raw, *raw.parents):
        if part.is_symlink() or (getattr(part.lstat(), 'st_file_attributes', 0) & 0x400 if part.exists() else False):
            raise ValueError('Linked workspace path refused')
    if raw.resolve().is_relative_to(ROOT):
        raise ValueError('Measurements must stay outside the repository')
    value = payload(source)
    raw.mkdir(mode=0o700, parents=True, exist_ok=True)
    for part in (raw, raw / 'metrics_logs', raw / 'metrics_logs/install_lab'):
        if part.is_symlink():
            raise ValueError('Linked metrics directory refused')
        part.mkdir(mode=0o700, exist_ok=True)
        if os.name == 'posix' and (part.stat().st_uid != os.getuid() or stat.S_IMODE(part.stat().st_mode) != 0o700):
            raise ValueError('Private owned metrics directories required')
    output = raw / 'metrics_logs/install_lab' / (uuid.uuid4().hex + '.json')
    create_new(output, json.dumps(value, indent=2, allow_nan=False).encode('utf-8'))
    return output


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('backup', 'import'))
    parser.add_argument('--input', required=True)
    parser.add_argument('--output')
    parser.add_argument('--workspace')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--complete-batch', action='store_true', help='Controller confirms the complete registry traversal, not all tests passed')
    args = parser.parse_args(argv)
    if not args.apply:
        print(json.dumps({'executed': False, 'action': args.action, 'scope': 'measurements-only'}))
        return 0
    if args.action == 'import' and args.complete_batch:
        raise ValueError('Import cannot promote completion status')
    if args.action == 'backup':
        if not args.output:
            raise ValueError('New backup output required')
        backup_report(args.input, args.output, batch_complete=True if args.complete_batch else None)
    else:
        if not args.workspace:
            raise ValueError('Explicit external workspace required')
        print(import_report(args.input, args.workspace))
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, TypeError, KeyError, tarfile.TarError):
        print('Measurement backup/import refused; no installation status restored.', file=__import__('sys').stderr)
        raise SystemExit(2)
