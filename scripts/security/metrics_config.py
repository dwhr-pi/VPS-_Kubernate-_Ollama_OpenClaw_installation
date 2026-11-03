"""Literal metrics data, never shell code; native POSIX publication with shared locking."""
import argparse
import contextlib
import hashlib
import json
import os
from pathlib import Path
import re
import secrets
import shlex
import stat
import sys

LIMIT = 2 * 1024 * 1024
SPECIAL = {'TARGET_DEVICE_NAME', 'TARGET_HOST_OS', 'TARGET_LINUX_OS', 'NOTES',
           'MIN_FREE_GB_RECOMMENDED', 'MIN_FREE_GB_ABSOLUTE', 'OVERVIEW_METRICS_ENABLED',
           'OVERVIEW_METRICS_MAX_ITEMS', 'GITHUB_TOOL_SOURCES_PREFERRED',
           'STRICT_GITHUB_TOOL_SOURCES', 'ALLOW_NON_GITHUB_TOOL_SOURCE'}
HISTORY = re.compile(r'LAST_[A-Z0-9_]+_(?:TIMESTAMP|STATUS|DURATION_SECONDS|FREE_(?:KB|GB)_(?:BEFORE|AFTER)|DELTA_KB)\Z')


def parse(data):
    if len(data) > LIMIT:
        raise ValueError('Metrics input too large')
    text = data.decode('utf-8-sig')
    rows = {}
    for line in text.splitlines():
        words = shlex.split(line, comments=True, posix=True)
        if not words:
            continue
        if len(words) != 1:
            raise ValueError('Single literal assignment required')
        key, separator, value = words[0].partition('=')
        if (not separator or not re.fullmatch(r'[A-Z][A-Z0-9_]{0,159}', key)
                or not (key in SPECIAL or key.endswith(('_ESTIMATE', '_REQUIRED_GB')) or HISTORY.fullmatch(key))
                or key in rows or any(ord(char) < 32 or ord(char) == 127 for char in value)
                or any(char in value for char in ('$', '`'))):
            raise ValueError('Unsupported metrics assignment')
        # Reject arithmetic expressions even when a later shell consumer uses a numeric value.
        if key.endswith(('_DURATION_SECONDS', '_FREE_KB_BEFORE', '_FREE_KB_AFTER',
                         '_FREE_GB_BEFORE', '_FREE_GB_AFTER', '_DELTA_KB')):
            if not re.fullmatch(r'-?[0-9]{1,18}', value):
                raise ValueError('Literal integer required')
        if key.startswith('MIN_FREE_GB_') or key == 'OVERVIEW_METRICS_MAX_ITEMS':
            if not re.fullmatch(r'[0-9]{1,9}', value):
                raise ValueError('Literal positive integer required')
        if key.endswith('_REQUIRED_GB') and not re.fullmatch(r'[0-9]{1,9}(?:-[0-9]{1,9})?', value):
            raise ValueError('Literal storage range required')
        rows[key] = value
    return rows


def checked(info, *, lock=False):
    if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_nlink != 1
            or info.st_mode & 0o022 or info.st_size > LIMIT
            or (lock and stat.S_IMODE(info.st_mode) != 0o600)):
        raise ValueError('Unsafe metrics metadata')


@contextlib.contextmanager
def store(path, *, write=True):
    if os.name != 'posix' or not hasattr(os, 'O_NOFOLLOW'):
        raise ValueError('Native POSIX required; no Windows or WSL fallback')
    if not path.is_absolute() or path.name != 'setup_metrics.conf' or '..' in path.parts:
        raise ValueError('Absolute metrics path required')
    repo = Path(__file__).resolve().parents[2]
    if path == repo or repo in path.parents:
        raise ValueError('Metrics must stay outside repository')
    import fcntl
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from private_env import directory
    with directory(path.parent) as parent:
        info = os.fstat(parent)
        if info.st_uid != os.getuid() or info.st_mode & 0o022:
            raise ValueError('Untrusted metrics parent')
        if not write:
            # Atomic writers let readers validate an immutable open-file snapshot without creating a lock.
            yield parent
            return
        fd = os.open('.setup-metrics.lock', os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW | os.O_NONBLOCK,
                     0o600, dir_fd=parent)
        try:
            checked(os.fstat(fd), lock=True)
            # The persistent lock inode must never be unlinked after release.
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            yield parent
        finally:
            os.close(fd)


def read(parent):
    try:
        fd = os.open('setup_metrics.conf', os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
    except FileNotFoundError:
        return None
    with os.fdopen(fd, 'rb') as stream:
        checked(os.fstat(stream.fileno()))
        data = stream.read(LIMIT + 1)
    parse(data)
    return data


def publish(parent, data, *, existed):
    parse(data)
    name = '.metrics-pending-' + secrets.token_hex(16)
    fd = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        if existed:
            checked(os.stat('setup_metrics.conf', dir_fd=parent, follow_symlinks=False))
            os.replace(name, 'setup_metrics.conf', src_dir_fd=parent, dst_dir_fd=parent)
        else:
            os.link(name, 'setup_metrics.conf', src_dir_fd=parent, dst_dir_fd=parent, follow_symlinks=False)
            os.unlink(name, dir_fd=parent)
        os.fsync(parent)
    finally:
        try:
            os.unlink(name, dir_fd=parent)
        except FileNotFoundError:
            pass


def merge(old, incoming):
    updates = parse(incoming)
    if not updates or any(not HISTORY.fullmatch(key) for key in updates):
        raise ValueError('Only measured history keys may be merged')
    parse(old)
    lines = [line for line in old.decode('utf-8-sig').splitlines()
             if line.partition('=')[0].strip() not in updates]
    lines += [key + '=' + json.dumps(value, ensure_ascii=False) for key, value in updates.items()]
    result = ('\n'.join(lines) + '\n').encode('utf-8')
    parse(result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', nargs='?', default='plan', choices=('plan', 'init', 'read', 'check', 'edit', 'merge'))
    parser.add_argument('--file', type=Path)
    parser.add_argument('--expected-sha')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args(argv)
    try:
        if args.dry_run or args.action == 'plan' or (args.action in ('init', 'edit', 'merge') and not args.apply):
            print('Nur Plan: literale Messwerte pruefen; kein Datei-/Hostzugriff oder Schreibvorgang.')
            return 0
        if args.file is None:
            raise ValueError('Metrics file required')
        with store(args.file, write=args.action not in ('read', 'check')) as parent:
            old = read(parent)
            if args.action == 'init' and old is not None:
                return 0
            if args.action in ('read', 'check', 'edit', 'merge') and old is None:
                raise ValueError('Existing metrics required')
            if args.action == 'check':
                print(hashlib.sha256(old).hexdigest())
            elif args.action == 'read':
                # Fully validate before emitting any assignments; Bash reads data, never eval/source.
                print('\n'.join(key + '\t' + value for key, value in parse(old).items()))
            else:
                data = sys.stdin.buffer.read(LIMIT + 1)
                parse(data)
                if args.action == 'edit':
                    if (not args.expected_sha or not re.fullmatch('[0-9a-f]{64}', args.expected_sha)
                            or hashlib.sha256(old).hexdigest() != args.expected_sha):
                        raise ValueError('Concurrent metrics update; preserve both versions')
                elif args.action == 'merge':
                    data = merge(old, data)
                publish(parent, data, existed=old is not None)
        return 0
    except (OSError, ValueError, UnicodeError):
        print('Messwerte abgelehnt; Format, Besitzer, Rechte oder parallele Aenderung pruefen. '
              'Keine Werte ausgefuehrt oder ausgegeben; Originaldatei bleibt bei Validierungsfehlern erhalten.',
              file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
