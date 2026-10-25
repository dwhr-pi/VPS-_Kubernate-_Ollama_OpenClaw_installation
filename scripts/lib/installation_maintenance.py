"""Kernel-held coordination between installers and explicit lock recovery."""
from contextlib import contextmanager
import os
from pathlib import Path
import stat


@contextmanager
def maintenance_guard(root, exclusive=False):
    if os.name != 'posix':
        if exclusive:
            raise ValueError('Installations-Reset nur unter Linux/WSL; kein Windows-Reset.')
        yield
        return
    import fcntl
    root = Path(root)
    if not root.is_absolute() or '..' in root.parts or root == Path(root.anchor):
        raise ValueError('Absoluter normalisierter Workspace erforderlich.')
    directory = root / 'install_transactions'
    for path in (directory, *directory.parents):
        if path.is_symlink():
            raise ValueError('Symlink im Wartungspfad; keine Aktion.')
    directory.mkdir(parents=True, mode=0o700, exist_ok=True)
    path = directory / '.maintenance.lock'
    fd = os.open(path, os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW | os.O_CLOEXEC, 0o600)
    try:
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_uid != os.geteuid() or info.st_mode & 0o077:
            raise ValueError('Unsichere Wartungssperre; keine Aktion.')
        try:
            fcntl.flock(fd, (fcntl.LOCK_EX if exclusive else fcntl.LOCK_SH) | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise ValueError('Installation oder Reset aktiv; Wartungssperre belegt. Nichts freigegeben.') from error
        try:
            yield
        finally:
            fcntl.flock(fd, fcntl.LOCK_UN)
    finally:
        os.close(fd)
    # Never unlink this inode: doing so would split concurrent lock ownership.
