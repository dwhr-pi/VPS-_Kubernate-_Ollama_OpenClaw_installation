"""Linux-only descriptor-relative private ENV publication; never evaluates values."""
import argparse
import contextlib
import os
from pathlib import Path
import secrets
import stat
import sys


@contextlib.contextmanager
def directory(path, *, create=False, private=False):
    """Hold every traversal under O_NOFOLLOW; reject writable/untrusted parents."""
    path = Path(path)
    if os.name != 'posix' or not hasattr(os, 'O_NOFOLLOW'):
        raise ValueError('Native Linux/Unix descriptor support required; no weaker fallback')
    if not path.is_absolute() or '..' in path.parts:
        raise ValueError('Absolute canonical directory required')
    fd = os.open('/', os.O_RDONLY | os.O_DIRECTORY)
    try:
        for index, part in enumerate(path.parts[1:]):
            final = index == len(path.parts) - 2
            info = os.fstat(fd)
            if info.st_uid not in (0, os.getuid()) or (
                    info.st_mode & 0o022 and not info.st_mode & stat.S_ISVTX):
                raise ValueError('Untrusted parent directory')
            try:
                child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            except FileNotFoundError:
                if not create or not final:
                    raise
                os.mkdir(part, 0o700, dir_fd=fd)
                child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            os.close(fd)
            fd = child
        info = os.fstat(fd)
        if private and (info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) != 0o700):
            raise ValueError('Private directory must belong to caller and have mode 0700')
        yield fd
    finally:
        os.close(fd)


def read_private(path, *, public_template=False):
    path = Path(path)
    with directory(path.parent) as parent:
        fd = os.open(path.name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
        with os.fdopen(fd, 'rb') as stream:
            info = os.fstat(stream.fileno())
            if (not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_size > 2 * 1024**2
                    or info.st_uid not in ((0, os.getuid()) if public_template else (os.getuid(),))
                    or info.st_mode & (0o022 if public_template else 0o077)):
                raise ValueError('Unsafe ENV input metadata')
            data = stream.read(2 * 1024**2 + 1)
            if len(data) > 2 * 1024**2:
                raise ValueError('ENV input too large')
            return data


def publish(parent, name, data, *, replace=False):
    """Parent is an already held private dirfd; publish complete bytes or nothing."""
    if name not in ('.env', '.env.template', 'prometheus.json', 'alertmanager.json', 'restore-evidence.json'):
        raise ValueError('Unapproved output name')
    try:
        info = os.stat(name, dir_fd=parent, follow_symlinks=False)
    except FileNotFoundError:
        info = None
    if info is not None and (not replace or not stat.S_ISREG(info.st_mode)
                             or info.st_uid != os.getuid() or info.st_nlink != 1
                             or stat.S_IMODE(info.st_mode) != 0o600):
        raise ValueError('Existing output preserved; private regular file and explicit replacement required')
    pending = '.pending-' + secrets.token_hex(16)
    fd = os.open(pending, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        if replace:
            # A replacement swaps directory entries, never follows a late symlink.
            os.replace(pending, name, src_dir_fd=parent, dst_dir_fd=parent)
        else:
            os.link(pending, name, src_dir_fd=parent, dst_dir_fd=parent, follow_symlinks=False)
            os.unlink(pending, dir_fd=parent)
        os.fsync(parent)
    finally:
        try:
            os.unlink(pending, dir_fd=parent)
        except FileNotFoundError:
            pass


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('prepare', 'apply'))
    parser.add_argument('--workspace', required=True, type=Path)
    parser.add_argument('--repo', required=True, type=Path)
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--replace', action='store_true')
    args = parser.parse_args(argv)
    try:
        workspace, repo = args.workspace.absolute(), args.repo.resolve(strict=True)
        if workspace == repo or repo in workspace.parents or not args.workspace.is_absolute():
            raise ValueError('Workspace must be absolute and outside repository')
        # Check/create the workspace itself without chmod/adoption of existing paths.
        with directory(workspace, create=True, private=True):
            pass
        with directory(workspace / 'llmops-platform', create=True, private=True) as target:
            name = '.env.template' if args.action == 'prepare' else '.env'
            if args.action == 'prepare':
                try:
                    os.stat(name, dir_fd=target, follow_symlinks=False)
                except FileNotFoundError:
                    pass
                else:
                    # Validate metadata before the manager may open an editor; do not read values.
                    fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=target)
                    try:
                        info = os.fstat(fd)
                        if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid()
                                or info.st_nlink != 1 or stat.S_IMODE(info.st_mode) != 0o600):
                            raise ValueError('Unsafe existing template')
                    finally:
                        os.close(fd)
                    return 0
            elif args.source != workspace / 'llmops-platform/.env.template':
                raise ValueError('Only the private workspace template may be applied')
            data = read_private(args.source, public_template=args.action == 'prepare')
            publish(target, name, data, replace=args.replace)
        print('Private ENV atomically published; no service or Docker action')
        return 0
    except (OSError, ValueError):
        print('ENV publication refused; existing files preserved. Check private ownership/modes and explicit replacement.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
