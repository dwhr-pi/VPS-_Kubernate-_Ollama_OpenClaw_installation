"""Deterministic registry views; default checks drift without executing tools or reading secrets."""
import argparse
import json
import os
from pathlib import Path
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from repository_audit import Audit

ROOT = Path(__file__).resolve().parents[2]
OUTPUTS = ('TOOL_MATRIX.md', 'PROFILE_MATRIX.md', 'PORT_MATRIX.md')


def cell(value):
    return str(value).replace('\\', '\\\\').replace('|', '\\|').replace('\n', ' ').replace('\r', ' ')


def render(root=ROOT):
    root = Path(root)
    audit = Audit(root)
    audit.registry()
    if audit.result()['errors']:
        raise ValueError('Registry ungueltig; keine Artefakte erzeugt.')
    outputs = {}
    for kind, name in zip(('tools', 'profiles', 'ports'), OUTPUTS):
        rows = json.loads((root / f'config/{kind}.yml').read_text(encoding='utf-8'))[kind]
        lines = [f'# Generierte {kind}-Matrix', '',
                 'Quelle: `config/' + kind + '.yml`. Nicht manuell bearbeiten.', '',
                 'Nur Repository-Metadaten, kein Nachweis installierter oder produktionsfaehiger Programme.', '']
        if kind == 'ports':
            lines += ['| Port | Dienst |', '| --- | --- |']
            lines += [f"| {r['port']} | {cell(r.get('service', 'unknown'))} |" for r in sorted(rows, key=lambda r: r['port'])]
        else:
            lines += ['| ID | Reifegrad (Legacy) | Bereitschaft | Pin | Doctor | Update |',
                      '| --- | --- | --- | --- | --- | --- |']
            for row in sorted(rows, key=lambda r: r['id'].casefold()):
                values = [row['id'], row.get('status', 'unknown'), row.get('readiness', 'unknown'),
                          row.get('source_commit', 'unknown'), row.get('doctor_script', 'not-mapped'),
                          row.get('update_script', 'not-mapped')]
                lines.append('| ' + ' | '.join(cell(v) for v in values) + ' |')
        outputs[name] = '\n'.join(lines) + '\n'
    return outputs


def artifacts(root, write=False):
    root = Path(root).resolve()
    target = root / 'docs/generated'
    for path in (target, target.parent):
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('Verlinktes Ausgabeziel abgelehnt.')
    expected = render(root)
    changed = []
    for name, content in expected.items():
        path = target / name
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('Verlinkte Ausgabedatei abgelehnt.')
        if path.exists() and not path.is_file():
            raise ValueError('Ausgabe ist keine Datei.')
        if path.exists() and path.read_text(encoding='utf-8') == content:
            continue
        changed.append(name)
        if write:
            target.mkdir(exist_ok=True)
            with tempfile.NamedTemporaryFile('w', dir=target, encoding='utf-8', newline='\n', delete=False) as file:
                temporary = Path(file.name)
                file.write(content)
            try:
                os.replace(temporary, path)
            finally:
                if temporary.exists():
                    temporary.unlink()
    return changed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--check', action='store_true')
    mode.add_argument('--write', action='store_true')
    args = parser.parse_args()
    try:
        changed = artifacts(ROOT, args.write)
        print(json.dumps({'scope': 'registry-metadata', 'write': args.write, 'drift': changed}))
        return int(bool(changed) and not args.write)
    except (OSError, ValueError):
        print('Registry-Generierung abgebrochen; Daten und Zielpfade pruefen.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
