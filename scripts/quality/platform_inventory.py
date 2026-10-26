"""Read-only full registry inventory; never executes installers or probes services."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
CLASSES = {'stable', 'beta', 'planned', 'deprecated', 'documentation-only'}


def script(root, value):
    if not value:
        return {'path': '', 'state': 'not-mapped'}
    if not isinstance(value, str) or '\\' in value or ':' in value:
        return {'path': '', 'state': 'unsafe-path'}
    relative = Path(value)
    if relative.is_absolute() or '..' in relative.parts or not (root / relative).resolve().is_relative_to(root.resolve()):
        return {'path': '', 'state': 'unsafe-path'}
    return {'path': value, 'state': 'present' if (root / relative).is_file() else 'missing-file'}


def review_class(row):
    declared = row.get('status')
    if declared in CLASSES:
        return declared
    # Conservative acceptance planning, never promote unknown/experimental to stable.
    if row.get('install_mode') in ('documentation-only', 'documentation-first'):
        return 'documentation-only'
    if not row.get('install') and not row.get('install_script') and row.get('doc'):
        return 'documentation-only'
    return 'planned'


def inventory(root=ROOT):
    root = Path(root)
    result = {'scope': 'registry-metadata-only', 'runtime_probes': False, 'writes': False,
              'rows': [], 'summary': {}}
    for kind in ('tools', 'profiles'):
        script_fields = ('install', 'uninstall', 'check', 'healthcheck', 'smoke_test',
                         'version', 'logs', 'doctor', 'update')
        rows = json.loads((root / 'config' / (kind + '.yml')).read_text(encoding='utf-8-sig'))[kind]
        if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
            raise ValueError('Registry muss eine Liste von Objekten enthalten.')
        ids = [row.get('id') for row in rows]
        if any(not isinstance(ident, str) or not ident for ident in ids) or len(set(ids)) != len(ids):
            raise ValueError('Fehlende oder doppelte Registry-ID.')
        for row in rows:
            fields = {'install': row.get('install_script') or row.get('install'),
                      'uninstall': row.get('uninstall_script') or row.get('uninstall'),
                      'check': row.get('check_script'), 'healthcheck': row.get('healthcheck_script'),
                      'smoke_test': row.get('smoke_test_script'), 'version': row.get('version_script'),
                      'logs': row.get('logs_script'), 'doctor': row.get('doctor_script'),
                      'update': row.get('update_script')}
            checks = {key: script(root, value) for key, value in fields.items()}
            result['rows'].append({'kind': kind, 'id': row['id'], 'name': row.get('name') or row['id'],
                'declared_status': row.get('status') or 'not-declared', 'review_class': review_class(row),
                'install_mode': row.get('install_mode') or 'not-declared',
                'target_hint': row.get('check_value') if row.get('check_type') == 'path' else 'not-declared',
                'dependencies': row.get('tools', row.get('dependencies', [])),
                'optional_dependencies': row.get('optional_tools', []),
                'ports': row.get('ports'), 'resource_class': row.get('resource_class') or 'not-declared',
                'check_type': row.get('check_type') or 'not-mapped', 'scripts': checks,
                'risk': row.get('risk') or 'not-assessed', 'readiness': 'not-tested',
                'doc': script(root, row.get('doc'))})
        selected = [row for row in result['rows'] if row['kind'] == kind]
        result['summary'][kind] = {'count': len(selected),
            'declared_status': dict(sorted(Counter(row['declared_status'] for row in selected).items())),
            'review_class': dict(sorted(Counter(row['review_class'] for row in selected).items())),
            'not_mapped': {key: sum(row['scripts'][key]['state'] == 'not-mapped' for row in selected) for key in script_fields}}
    return result


def markdown(report, kind='all', revision='not-specified'):
    def cell(value):
        if isinstance(value, list):
            value = ', '.join(map(str, value)) or 'keine registriert'
        return str(value if value is not None else 'nicht deklariert').replace('|', '&#124;').replace('\n', ' ').replace('\r', ' ')

    def file(info):
        return ('[' + cell(info['path']) + '](../../' + info['path'] + ')' if info['path'] else '-') + ' (' + info['state'] + ')'

    lines = ['# Vollinventar: ' + kind, '', 'Repository-Revision: `' + revision + '`.', '',
        'Nur Registry und Dateiexistenz; keine Installation, Dienste, Cloud oder Secrets geprueft.',
        'Reviewklasse = konservative Abnahmeplanung, keine Registry-Aenderung oder Produktionsfreigabe.',
        'Unbekannt/experimental/optional wird ohne weiteren Beleg planned; vorhandene stable/beta bleiben nur deklarierte Labels.',
        'Zielhinweis aus check_value ist kein verifizierter Installationspfad. Fehlendes Mapping beweist nicht das Fehlen einer Funktion im Installer.', '',
        '| Eintrag / Reviewklasse | Registry-Status | Install-Skript / Zielhinweis | Abhaengigkeiten | Ports | Ressourcenklasse | Check / Health / Smoke / Version / Logs | Uninstall | Test / Reife | Risiko |',
        '|---|---|---|---|---|---|---|---|---|---|']
    for row in sorted(report['rows'], key=lambda row: (row['kind'], row['name'].casefold())):
        if kind != 'all' and row['kind'] != kind:
            continue
        checks = row['scripts']
        dependencies = cell(row['dependencies']) if row['dependencies'] else 'nicht zentral deklariert'
        if row['optional_dependencies']:
            dependencies += '; optional: ' + cell(row['optional_dependencies'])
        contract = ', '.join(key + ':' + checks[key]['state'] for key in ('healthcheck', 'smoke_test', 'version', 'logs', 'doctor'))
        lines.append('| ' + ' | '.join(map(cell, [row['kind'] + ':' + row['id'] + ' / ' + row['review_class'],
            row['declared_status'], file(checks['install']) + '; Ziel: ' + str(row['target_hint']),
            dependencies, row['ports'], row['resource_class'],
            row['check_type'] + '; ' + contract, file(checks['uninstall']), row['readiness'] + '; keine Abnahme', row['risk']])) + ' |')
    lines += ['', 'Ende des metadatenbasierten Inventars.']
    return '\n'.join(lines) + '\n'


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--markdown', action='store_true')
    parser.add_argument('--kind', choices=('all', 'tools', 'profiles'), default='all')
    parser.add_argument('--revision', default='not-specified')
    args = parser.parse_args(argv)
    if args.revision != 'not-specified' and not re.fullmatch('[a-f0-9]{40}', args.revision):
        parser.error('Revision muss ein voller Commit-Hash sein.')
    report = inventory()
    print(markdown(report, args.kind, args.revision) if args.markdown else json.dumps(report, indent=2), end='\n')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
