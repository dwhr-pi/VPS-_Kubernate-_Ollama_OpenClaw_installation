"""Resolve lifecycle actions through the registry, without executing any script."""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]


def resolve(root, requested, action):
    root = Path(root).resolve()
    if not isinstance(requested, str) or not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9 _-]{0,127}', requested):
        raise ValueError('Ungueltige Tool-ID bzw. registrierter Name')
    rows = json.loads((root / 'config/tools.yml').read_text(encoding='utf-8-sig'))['tools']
    matches = [row for row in rows if requested.casefold() in
               (str(row.get('id', '')).casefold(), str(row.get('name', '')).casefold())]
    if len(matches) != 1:
        raise ValueError('Tool ist nicht eindeutig in der Registry enthalten')
    value = matches[0].get(action + '_script')
    if not isinstance(value, str) or not re.fullmatch(r'scripts/tools/[A-Za-z0-9_-]+_' + action + r'\.sh', value):
        raise ValueError('Kein explizit registriertes, sicheres Lifecycle-Skript')
    relative = Path(value)
    path = root
    for part in relative.parts:
        path = path / part
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('Verlinkte Lifecycle-Pfade sind nicht erlaubt')
    if not path.resolve().is_relative_to(root / 'scripts/tools') or not path.is_file():
        raise ValueError('Lifecycle-Skript fehlt oder liegt ausserhalb scripts/tools')
    return path


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tool')
    parser.add_argument('--action', choices=['update', 'uninstall'], required=True)
    args = parser.parse_args(argv)
    try:
        print(resolve(ROOT, args.tool, args.action))
    except (ValueError, KeyError, OSError) as error:
        print('Lifecycle-Aufloesung abgelehnt: ' + str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
