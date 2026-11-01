"""Bounded file-level TAR restore drill; never starts services or claims database/PVC recovery."""
import argparse
import hashlib
import io
import json
import os
import platform
import re
from pathlib import Path, PurePosixPath
import shutil
import stat
import sys
import tarfile
import tempfile

LIMIT = 2 * 1024**3
MAX_FILES = 10000


def safe_name(name):
    path = PurePosixPath(name)
    if (not name or name == '.' or len(name) > 1024 or len(path.parts) > 32
            or any(ord(char) < 32 or ord(char) == 127 for char in name)
            or path.is_absolute() or '..' in path.parts or path.as_posix() != name
            or '\\' in name or ':' in name):
        raise ValueError('Unsafe archive member')
    return path


def restore(archive, manifest, destination, *, max_bytes=LIMIT):
    """Restore to a new private destination; partial output is retained on failure."""
    archive, manifest, destination = map(Path, (archive, manifest, destination))
    for path in (archive, *archive.parents, manifest, *manifest.parents, destination, *destination.parents):
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('Linked restore paths are forbidden')
    if destination.exists() or not destination.is_absolute() or not destination.parent.is_dir():
        raise ValueError('New absolute destination with existing parent required')
    if (not archive.is_file() or not manifest.is_file() or manifest.stat().st_size > 4 * 1024**2
            or archive.stat().st_size > max_bytes + 32 * 1024**2):
        raise ValueError('Missing or oversized restore inputs')
    data = json.loads(manifest.read_text(encoding='utf-8'))
    if not isinstance(data, dict):
        raise ValueError('Invalid manifest document')
    entries = data.get('files')
    if data.get('schema') != 1 or not isinstance(entries, dict) or not 1 <= len(entries) <= MAX_FILES:
        raise ValueError('Unsupported file manifest')
    for name, row in entries.items():
        safe_name(name)
        if (not isinstance(row, dict) or type(row.get('size')) is not int or row['size'] < 0
                or not isinstance(row.get('sha256'), str) or not re.fullmatch('[0-9a-f]{64}', row['sha256'])):
            raise ValueError('Invalid file contract')
    total = sum(row['size'] for row in entries.values())
    if total > max_bytes or shutil.disk_usage(destination.parent).free < total + 64 * 1024**2:
        raise ValueError('Restore size/reserve exceeded')
    with tarfile.open(archive, 'r:') as tar:
        members = {}
        for item in tar:
            safe_name(item.name)
            if not item.isfile() or item.name in members or item.name not in entries:
                raise ValueError('Links, directories, duplicates or unexpected files forbidden')
            if item.size != entries[item.name]['size']:
                raise ValueError('Archive size differs from manifest')
            members[item.name] = item
            if len(members) > MAX_FILES:
                raise ValueError('Too many members')
        if set(members) != set(entries):
            raise ValueError('Incomplete backup')
        destination.mkdir(mode=0o700)
        for name, item in members.items():
            target = destination.joinpath(*safe_name(name).parts)
            target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
            digest = hashlib.sha256()
            stream = tar.extractfile(item)
            if stream is None:
                raise ValueError('Missing member stream')
            flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, 'O_NOFOLLOW', 0)
            with stream, os.fdopen(os.open(target, flags, 0o600), 'wb') as output:
                remaining = item.size
                while remaining:
                    chunk = stream.read(min(remaining, 65536))
                    if not chunk:
                        raise ValueError('Truncated restore')
                    output.write(chunk)
                    digest.update(chunk)
                    remaining -= len(chunk)
            if digest.hexdigest() != entries[name]['sha256']:
                raise ValueError('Integrity mismatch; partial restore retained')
    return {'scope': 'file-integrity-only', 'files': len(entries), 'bytes': total,
            'result': 'passed', 'runtime_verified': False, 'database_consistency_verified': False}


def fixture():
    # All data and output belong to this disposable fixture, never a real workspace.
    with tempfile.TemporaryDirectory(prefix='ultimate-restore-fixture-') as directory:
        root = Path(directory).resolve()
        payloads = {'config/example.txt': b'synthetic configuration\n', 'data/example.txt': b'synthetic data\n'}
        archive = root / 'fixture.tar'
        rows = {}
        with tarfile.open(archive, 'w') as tar:
            for name, content in payloads.items():
                item = tarfile.TarInfo(name)
                item.size = len(content)
                tar.addfile(item, io.BytesIO(content))
                rows[name] = {'size': len(content), 'sha256': hashlib.sha256(content).hexdigest()}
        manifest = root / 'manifest.json'
        manifest.write_text(json.dumps({'schema': 1, 'files': rows}))
        result = restore(archive, manifest, root / 'recovered')
        result['scope'] = 'synthetic-file-restore-fixture'
        return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', '--dry-run', action='store_true')
    parser.add_argument('--fixture', action='store_true')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--archive', type=Path)
    parser.add_argument('--manifest', type=Path)
    parser.add_argument('--destination', type=Path)
    parser.add_argument('--allow-sensitive-data', action='store_true')
    args = parser.parse_args(argv)
    try:
        if args.plan or not args.apply:
            print(json.dumps({'mode': 'plan', 'writes': False, 'reads_backup_data': False,
                              'runtime_verified': False, 'requires': 'explicit apply and new recovery destination'}))
            return 3
        if args.fixture:
            if any((args.archive, args.manifest, args.destination, args.allow_sensitive_data)):
                raise ValueError('Fixture cannot use external inputs')
            result = fixture()
        else:
            if (os.name != 'posix' or platform.system() != 'Linux' or os.geteuid() == 0 or os.environ.get('WSL_DISTRO_NAME')
                    or 'microsoft' in platform.release().lower() or not args.allow_sensitive_data
                    or not all((args.archive, args.manifest, args.destination))):
                raise ValueError('Real restore requires non-root Linux and explicit data approval')
            if not all(path.is_absolute() for path in (args.archive, args.manifest, args.destination)):
                raise ValueError('Absolute restore input and output paths required')
            parent = args.destination.parent
            if (parent.stat().st_uid != os.geteuid() or stat.S_IMODE(parent.stat().st_mode) != 0o700):
                raise ValueError('Private operator-owned recovery parent required')
            result = restore(args.archive, args.manifest, args.destination)
        print(json.dumps(result))
        return 0
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError):
        print('Restore-Drill fehlgeschlagen; eventuellen Teilbestand privat pruefen. '
              'Kein Dienst-/DB-/PVC-Restore bestaetigt.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
