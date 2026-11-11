"""Synthetic backup/restore evidence only; never reads an operator backup or private workspace."""
import argparse
from datetime import datetime, timezone
import importlib.util
import json
import os
from pathlib import Path
import sys
import time


def fixture():
    spec = importlib.util.spec_from_file_location('restore_drill', Path(__file__).with_name('restore_drill.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.fixture()


def write_report(path, result):
    if not path.is_absolute():
        raise ValueError('Absolute evidence path required')
    for part in (path, *path.parents):
        if part.is_symlink() or (hasattr(part, 'is_junction') and part.is_junction()):
            raise ValueError('Linked evidence paths forbidden')
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, 'O_NOFOLLOW', 0)
    with os.fdopen(os.open(path, flags, 0o600), 'w', encoding='utf-8') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--fixture', action='store_true')
    parser.add_argument('--dry-run', '--plan', action='store_true')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args(argv)
    if args.dry_run or not args.apply:
        print(json.dumps({'mode': 'plan', 'writes': False, 'reads_backup_data': False,
                          'runtime_verified': False, 'requires': '--fixture --apply'}))
        return 3
    if not args.fixture:
        parser.error('Only --fixture --apply is supported; real restores use restore_test.sh')
    started = time.monotonic()
    try:
        result = fixture()
        result.update(schema=1, completed_at=datetime.now(timezone.utc).isoformat(),
                      elapsed_seconds=round(time.monotonic() - started, 3), checksum='sha256',
                      production_backup_verified=False, offsite_verified=False)
        if args.report:
            write_report(args.report, result)
        print(json.dumps(result))
        return 0
    except (OSError, ValueError):
        print('Synthetischer Restore/Nachweis fehlgeschlagen; keine Produktionsabnahme.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
