"""Pure offline menu ordering: frozen catalog A-Z, future keys appended, no tool execution."""
import argparse
import os
from pathlib import Path
import re
import stat
import sys

CORE = {'Ollama', 'OpenClaw', 'Ruflo'}
KEY = re.compile(r'[A-Za-z0-9_-]+')


def read_baseline(path):
    path = Path(path)
    if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
        raise ValueError('Linked baseline')
    before = path.stat()
    if not stat.S_ISREG(before.st_mode) or not 0 < before.st_size <= 65536:
        raise ValueError('Invalid baseline size/type')
    descriptor = os.open(path, os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0) | getattr(os, 'O_BINARY', 0))
    with os.fdopen(descriptor, 'rb') as stream:
        opened = os.fstat(stream.fileno())
        if (opened.st_dev, opened.st_ino) != (before.st_dev, before.st_ino):
            raise ValueError('Baseline replaced before open')
        payload = stream.read(65537)
    if len(payload) > 65536:
        raise ValueError('Baseline grew beyond limit')
    result = set()
    for line in payload.decode('utf-8-sig').splitlines():
        if not line or line.startswith('#'):
            continue
        if not KEY.fullmatch(line) or line in result or line in CORE:
            raise ValueError('Invalid or duplicate baseline key')
        result.add(line)
    if not result:
        raise ValueError('Empty baseline')
    return result


def ordered(keys, baseline):
    if len(keys) > 10000 or len(keys) != len(set(keys)) or any(not KEY.fullmatch(key) for key in keys):
        raise ValueError('Invalid or duplicate menu key')
    pinned = [key for key in keys if key in CORE]
    existing = sorted((key for key in keys if key not in CORE and key in baseline), key=str.upper)
    appended = [key for key in keys if key not in CORE and key not in baseline]
    return pinned + existing + appended


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', required=True, type=Path)
    parser.add_argument('keys', nargs='*')
    args = parser.parse_args(argv)
    try:
        result = ordered(args.keys, read_baseline(args.baseline))
        if result:
            print('\n'.join(result))
        return 0
    except (OSError, ValueError):
        print('Tool-Sortierung fehlgeschlagen; Basis und Menueschluessel pruefen. Reihenfolge unveraendert.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
