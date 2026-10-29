"""Atomic writes for fixed, non-secret audit outputs; never mutate hardlink peers."""
import os
from pathlib import Path
import tempfile

ALLOWED = {'inventory.json', 'TOOL_INVENTORY.md', 'test_results.json', 'test_recheck_results.json'}


def write_report(root, name, content):
    if name not in ALLOWED:
        raise ValueError('Unknown audit output')
    root = Path(root).resolve()
    directory = root / 'docs/audit'
    for parent in (root / 'docs', directory):
        if parent.is_symlink() or (hasattr(parent, 'is_junction') and parent.is_junction()):
            raise ValueError('Linked report directory rejected')
        parent.mkdir(exist_ok=True)
    path = directory / name
    if (path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction())
            or (path.exists() and not path.is_file())):
        raise ValueError('Linked or non-regular report target rejected')
    descriptor, temporary = tempfile.mkstemp(dir=directory, prefix='.audit-stage-')
    temporary = Path(temporary)
    try:
        with os.fdopen(descriptor, 'w', encoding='utf-8', newline='\n') as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        # Replacing the directory entry does not write through existing hardlinks.
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)
