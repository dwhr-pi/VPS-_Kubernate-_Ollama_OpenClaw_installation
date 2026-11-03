"""Restic backup of consistent exports, or isolated file-restore verification; no Docker."""
import argparse
import hashlib
import importlib.util
import ipaddress
import json
import os
from pathlib import Path
import platform
import re
import shutil
import stat
import subprocess
import sys
import tempfile
from urllib.parse import urlsplit

spec = importlib.util.spec_from_file_location('private_env', Path(__file__).with_name('private_env.py'))
private = importlib.util.module_from_spec(spec)
spec.loader.exec_module(private)
ALLOWED = {'RESTIC_REPOSITORY', 'RESTIC_PASSWORD_FILE', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY',
           'AWS_SESSION_TOKEN', 'AWS_DEFAULT_REGION'}


def environment(path):
    values = {}
    for line in private.read_private(path).decode('utf-8').splitlines():
        if not line or line.startswith('#'):
            continue
        key, separator, value = line.partition('=')
        if not separator or key not in ALLOWED or key in values or not value:
            raise ValueError('Literal allowlisted KEY=VALUE required, no quoting/expansion')
        values[key] = value
    repo = values.get('RESTIC_REPOSITORY', '')
    url = urlsplit(repo[3:] if repo.startswith('s3:') else '')
    if (url.scheme != 'https' or not url.hostname or url.username or url.password
            or url.query or url.fragment or not url.path.strip('/')):
        raise ValueError('Explicit HTTPS S3 repository required')
    if url.hostname.lower() in ('localhost', 'minio'):
        raise ValueError('Primary/local MinIO is not an independent backup target')
    try:
        ip = ipaddress.ip_address(url.hostname)
    except ValueError:
        pass
    else:
        if ip.is_loopback or ip.is_link_local or ip.is_unspecified:
            raise ValueError('Local/metadata backup endpoints forbidden')
    if not values.get('AWS_ACCESS_KEY_ID') or not values.get('AWS_SECRET_ACCESS_KEY'):
        raise ValueError('Explicit dedicated S3 credentials required; no inherited profile lookup')
    password = values.get('RESTIC_PASSWORD_FILE', '')
    if not Path(password).is_absolute() or not private.read_private(Path(password)).strip():
        raise ValueError('Private password file required')
    # No inherited Restic hooks, passwords, proxy overrides or alternate repository settings.
    env = {key: os.environ[key] for key in ('PATH', 'LANG', 'LC_ALL', 'HOME') if key in os.environ}
    env.update(values)
    env.update(AWS_CONFIG_FILE='/dev/null', AWS_SHARED_CREDENTIALS_FILE='/dev/null',
               AWS_EC2_METADATA_DISABLED='true')
    return env


def verify_exports(root):
    """Manifest describes OFFLINE exports, not mutable database volume directories."""
    root = Path(root)
    with private.directory(root, private=True):
        data = json.loads(private.read_private(root / 'backup-manifest.json'))
        if not isinstance(data, dict):
            raise ValueError('Invalid manifest object')
        rows = data.get('files')
        if data.get('schema') != 1 or not isinstance(rows, dict) or not 3 <= len(rows) <= 10000:
            raise ValueError('Manifest requires postgres, qdrant and minio exports')
        services = set()
        for name, row in rows.items():
            if not isinstance(name, str):
                raise ValueError('Invalid export path')
            parts = name.split('/')
            if (len(parts) < 2 or parts[0] not in ('postgres', 'qdrant', 'minio')
                    or any(not re.fullmatch('[A-Za-z0-9_.-]+', part) or part in ('.', '..') for part in parts)
                    or not isinstance(row, dict) or type(row.get('size')) is not int or row['size'] < 0
                    or not isinstance(row.get('sha256'), str)
                    or not re.fullmatch('[a-f0-9]{64}', row['sha256'])):
                raise ValueError('Invalid export manifest')
            path = root.joinpath(*parts)
            with private.directory(path.parent, private=True) as parent:
                fd = os.open(path.name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
                with os.fdopen(fd, 'rb') as stream:
                    info = os.fstat(stream.fileno())
                    if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_nlink != 1
                            or stat.S_IMODE(info.st_mode) != 0o600 or info.st_size != row['size']):
                        raise ValueError('Unsafe/mismatched export file')
                    digest = hashlib.file_digest(stream, 'sha256').hexdigest()
            if digest != row['sha256']:
                raise ValueError('Export integrity mismatch')
            services.add(parts[0])
        if services != {'postgres', 'qdrant', 'minio'}:
            raise ValueError('Incomplete service export set')
        actual = set()
        for folder, dirs, files in os.walk(root, followlinks=False):
            for name in dirs + files:
                path = Path(folder) / name
                if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
                    raise ValueError('Linked export tree forbidden')
                if path.is_dir():
                    with private.directory(path, private=True):
                        pass
                else:
                    actual.add(path.relative_to(root).as_posix())
            if len(actual) > 10001:
                raise ValueError('Export count exceeded')
        if actual != set(rows) | {'backup-manifest.json'}:
            raise ValueError('Unlisted files or incomplete export')
    return {'files': len(rows), 'file_integrity_verified': True, 'database_restore_verified': False,
            'pvc_restore_verified': False, 'runtime_verified': False}


def restic(binary, args, env, cwd):
    result = subprocess.run([binary, '--no-cache', *args], cwd=cwd, env=env, stdin=subprocess.DEVNULL,
                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=7200, check=False)
    if result.returncode:
        # In particular, restic exit 3 is a partial backup, never success.
        raise ValueError('Restic failed/partial; no success receipt. Inspect locally without publishing credentials.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('backup', 'restore'))
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--env-file', type=Path)
    parser.add_argument('--exports', type=Path)
    parser.add_argument('--recovery-parent', type=Path)
    parser.add_argument('--snapshot')
    parser.add_argument('--confirm-consistent-exports', action='store_true')
    parser.add_argument('--confirm-external-target', action='store_true')
    args = parser.parse_args(argv)
    if not args.apply:
        print('Plan only: encrypted Restic repository; consistent exports; new isolated recovery directory. No credentials read or network.')
        return 3
    try:
        if (platform.system() != 'Linux' or os.geteuid() == 0 or not args.env_file
                or not args.confirm_consistent_exports or not args.confirm_external_target):
            raise ValueError('Non-root Linux, private env and explicit consistent-export approval required')
        repo = Path(__file__).resolve().parents[2]
        for path in (args.env_file, args.exports, args.recovery_parent):
            if path is not None and (not path.is_absolute() or '..' in path.parts
                                     or path == repo or repo in path.parents):
                raise ValueError('Private backup inputs/outputs must stay outside repository')
        binary = shutil.which('restic')
        if not binary:
            raise ValueError('Native Git-built Restic required; no download or Docker fallback')
        env = environment(args.env_file)
        if args.action == 'backup':
            if not args.exports or not args.exports.is_absolute():
                raise ValueError('Absolute private export directory required')
            verify_exports(args.exports)
            # Only named, prevalidated files are included; never a live DB volume or whole workspace.
            rows = json.loads(private.read_private(args.exports / 'backup-manifest.json'))['files']
            restic(binary, ['backup', '--tag', 'consistent-exports', '--', 'backup-manifest.json', *sorted(rows)], env, args.exports)
            verify_exports(args.exports)
            print('Restic backup command succeeded; no database/PVC restore acceptance claimed.')
        else:
            if not args.snapshot or not re.fullmatch('[0-9a-f]{64}', args.snapshot) or not args.recovery_parent:
                raise ValueError('Exact full snapshot ID and private recovery parent required; no latest/in-place restore')
            with private.directory(args.recovery_parent, private=True):
                target = Path(tempfile.mkdtemp(prefix='restic-drill-', dir=args.recovery_parent))
            print('Isolated recovery directory (partial output retained on failure):', target)
            restic(binary, ['restore', args.snapshot, '--verify', '--target', str(target)], env, args.recovery_parent)
            # Restic stores explicit relative file paths from the export working directory.
            result = verify_exports(target)
            result.update(snapshot=args.snapshot, scope='restic-export-file-integrity-only')
            with private.directory(target, private=True) as parent:
                private.publish(parent, 'restore-evidence.json', json.dumps(result, indent=2).encode())
            print('File-integrity drill passed. Database import, object semantics and PVC recovery remain unverified.')
        return 0
    except (OSError, ValueError, UnicodeError, subprocess.SubprocessError):
        print('Backup/restore refused or incomplete; no success receipt, no cleanup of user data, no raw credential output.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
