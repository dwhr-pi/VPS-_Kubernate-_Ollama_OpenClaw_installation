"""Read-only safety stop for legacy core installs without trusted ownership receipts."""
import argparse
import json
import os
from pathlib import Path, PurePosixPath
import stat
import sys


PLANNED = 3
BLOCKED = 1
INVALID = 2
ARTIFACTS = {
    'ollama': ('usr/local/bin/ollama', 'usr/bin/ollama',
               'etc/systemd/system/ollama.service', 'usr/share/ollama', 'var/lib/ollama'),
    'openclaw': ('opt/openclaw', 'etc/systemd/system/openclaw.service'),
}
MARKER = '.openclaw-install-owner'


class GuardError(ValueError):
    pass


class Parser(argparse.ArgumentParser):
    def error(self, message):
        # Unknown option values may contain accidentally pasted credentials.
        self.print_usage(sys.stderr)
        self.exit(INVALID, 'Ungueltige Optionen; kein Ziel oder Force-Modus erlaubt.\n')


def linked(path, info):
    return stat.S_ISLNK(info.st_mode) or (
        hasattr(path, 'is_junction') and path.is_junction())


def inspect_artifact(root, relative):
    """Inspect fixed metadata only; never resolve links or read payload/marker contents."""
    original = str(relative)
    relative = PurePosixPath(relative)
    if (relative.is_absolute() or not relative.parts or
            any(part in ('..', '.') for part in relative.parts) or
            relative.as_posix() != original or '\\' in original or ':' in original):
        raise GuardError('Nicht freigegebener Zielpfad; keine Aktion.')
    root = Path(root)
    if not root.is_absolute() or '..' in root.parts:
        raise GuardError('Inspektionswurzel muss absolut sein.')
    result = {'path': '/' + relative.as_posix(), 'state': 'absent', 'ownership': 'unproven'}
    path = root
    for component in (root, *root.parents):
        metadata = component.lstat()
        if linked(component, metadata):
            raise GuardError('Verlinkte Inspektionswurzel; keine Aktion.')
    for index, part in enumerate(relative.parts):
        path = path / part
        try:
            metadata = path.lstat()
        except FileNotFoundError:
            return result
        if linked(path, metadata):
            result['state'] = 'linked-path-preserved'
            return result
        if index < len(relative.parts) - 1 and not stat.S_ISDIR(metadata.st_mode):
            result['state'] = 'invalid-parent-preserved'
            return result
    result.update(state='present-preserved', owner_uid=metadata.st_uid)
    if stat.S_ISDIR(metadata.st_mode):
        try:
            marker = path / MARKER
            receipt = marker.lstat()
        except FileNotFoundError:
            result['marker'] = 'missing'
        else:
            private = (stat.S_ISREG(receipt.st_mode) and not linked(marker, receipt)
                       and receipt.st_nlink == 1 and receipt.st_uid == metadata.st_uid
                       and stat.S_IMODE(receipt.st_mode) == 0o600
                       and stat.S_IMODE(metadata.st_mode) == 0o700)
            # Rollback tokens or hand-written JSON are not installer provenance.
            result['marker'] = 'private-but-unverified' if private else 'unsafe-preserved'
    return result


def validate_environment(environment):
    if environment.get('OPENCLAW_DIR', '/opt/openclaw') != '/opt/openclaw':
        raise GuardError('OPENCLAW_DIR darf den festen Legacy-Pfad nicht umleiten.')
    for key in ('OPENCLAW_REMOVE_STATE', 'OPENCLAW_UNINSTALL_ASSUME_YES', 'OPENCLAW_BACKUP_STATE'):
        value = environment.get(key, '')
        if not isinstance(value, str):
            raise GuardError('Ungueltige Legacy-Variable; keine Aktion.')
        value = value.lower()
        if value not in ('', 'no', 'false', '0', 'prompt'):
            raise GuardError('Legacy-Freigabe-/Backup-Variable abgelehnt; nichts geaendert.')


def plan(tool, root=Path('/')):
    if tool not in ARTIFACTS:
        raise GuardError('Unbekanntes Core-Tool.')
    return {'tool': tool, 'mode': 'read-only', 'removal_authorized': False,
            'reason': 'legacy-installer-has-no-trusted-ownership-receipt',
            'artifacts': [inspect_artifact(root, item) for item in ARTIFACTS[tool]],
            'preserved': ['programs', 'services', 'models', 'agent-state',
                          'credentials', 'workspace', 'installed-status', 'autostart']}


def main(argv=None, *, root=Path('/'), environment=None):
    parser = Parser(description='Legacy-Uninstall-Vorschau; keine automatische Entfernung.')
    parser.add_argument('tool', choices=tuple(ARTIFACTS))
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--dry-run', action='store_true')
    modes.add_argument('--apply', action='store_true')
    args = parser.parse_args(argv)
    try:
        validate_environment(os.environ if environment is None else environment)
        if args.apply:
            # No marker producer exists for these legacy installers. Do not adopt them.
            raise GuardError('Automatische Legacy-Deinstallation gesperrt: kein gepruefter '
                             'Besitz-/Migrationsvertrag. Keine Dienste oder Daten geaendert. '
                             'Siehe docs/P0_A_CORE_UNINSTALL.md.')
        print(json.dumps(plan(args.tool, root), ensure_ascii=True, indent=2))
        print('Nur Vorschau/Sicherheitssperre; NICHT deinstalliert. '
              'Status und Autostart bleiben erhalten. Siehe docs/P0_A_CORE_UNINSTALL.md.')
        # Zero would let existing callers incorrectly mark an installation as removed.
        return PLANNED
    except GuardError as error:
        print(str(error), file=sys.stderr)
        return BLOCKED
    except (OSError, ValueError):
        print('Core-Uninstall abgelehnt: Ziel, Metadaten oder Freigabe nicht sicher pruefbar. '
              'Legacy-Entfernung ist gesperrt; nichts geaendert. '
              'Siehe docs/P0_A_CORE_UNINSTALL.md.', file=sys.stderr)
        return BLOCKED


if __name__ == '__main__':
    sys.exit(main())
