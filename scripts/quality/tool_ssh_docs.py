"""Generate VPS SSH examples in tool guides without executing their commands."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('ssh_catalog', ROOT / 'scripts/tool_commands.py')
catalog = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(catalog)
START = '<!-- BEGIN GENERATED VPS SSH -->'
END = '<!-- END GENERATED VPS SSH -->'
REPORT = 'docs/generated/SSH_TOOL_COVERAGE.md'


def normalized(value):
    return re.sub('[^a-z0-9]', '', value.casefold())


def guides(root=ROOT, rows=None):
    rows = catalog.catalog(root) if rows is None else rows
    base = root / 'docs/tools'
    if base.is_symlink() or (hasattr(base, 'is_junction') and base.is_junction()):
        raise ValueError('Verlinktes Dokumentationsverzeichnis')
    names = {p.relative_to(root).as_posix() for p in base.rglob('*.md')}
    names.update(row['doc'] for row in rows if row['doc'])
    result = {}
    for name in sorted(names):
        if not name.startswith('docs/') or not name.endswith('.md') or not catalog.file_in_repo(root, name):
            raise ValueError('Unsicheres Dokumentationsziel')
        result[name] = [row for row in rows if row['doc'] == name or
                        (name.startswith('docs/tools/') and normalized(Path(name).stem) == normalized(row['id']))]
    return result


def render(name, rows):
    parent = Path(name).parent.as_posix()
    guide = os.path.relpath('docs/HEADLESS_SETUP.md', parent).replace('\\', '/')
    table = os.path.relpath('docs/generated/HEADLESS_TOOL_COMMANDS.md', parent).replace('\\', '/')
    lines = [START, '', '## VPS ueber SSH bedienen', '',
             'Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter',
             'SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).',
             'Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher',
             'unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.', '',
             'Auf deinem Client (PowerShell, Linux oder macOS):', '', '```bash',
             'ssh -t vps', '```', '',
             'Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;',
             'ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:', '', '```bash',
             'cd "$HOME/openclaw_ultimate_setup" || exit 1',
             'test -f scripts/tool_commands.py || exit 1', '```', '',
             'Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):', '', '```bash']
    if rows:
        lines += ['python3 -I -B scripts/tool_commands.py show ' + row['id'] for row in rows]
    else:
        lines += ['python3 -I -B scripts/tool_commands.py list']
    lines += ['```', '']
    for row in rows:
        key = row['id']
        lines += ['### SSH-Aktionen: `' + key + '`', '']
        if row['unattended'] == 'not-reviewed':
            lines += ['Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt',
                      'vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die',
                      'tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.', '',
                      'Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im',
                      'VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool',
                      f"`{row.get('name', key)}` (ID `{key}`) waehlen und die Einzelfreigaben lesen.",
                      'Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine',
                      'Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.', '']
            continue
        lines += ['Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:', '', '```bash',
                  f'python3 -I -B scripts/tool_commands.py run {key} --action status',
                  f'python3 -I -B scripts/tool_commands.py run {key} --action doctor', '```', '',
                  'Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als',
                  'gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.',
                  'Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.', '',
                  ]
        for action, label in (('install', 'Installieren'), ('update', 'Aktualisieren'), ('uninstall', 'Deinstallieren')):
            lines += [label + ' (separate Entscheidung):', '', '```bash',
                      f'python3 -I -B scripts/tool_commands.py run {key} --action {action} --apply --confirm {key}:{action}',
                      '```', '']
        lines += [
                  'Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update',
                  '`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,',
                  'kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.', '']
        if row['config_script']:
            lines += ['Optionaler interaktiver Konfigurationsdialog auf dem VPS:', '', '```bash',
                      'bash ' + row['config_script'], '```', '']
    lines += ['Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:', '',
              '```bash', 'bash setup_ultimate.sh', '```', '',
              'Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.',
              'Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;',
              'zum Verlassen des VPS-Terminals `exit` verwenden.', '',
              f'[SSH-Voraussetzungen und Sicherheitsgrenzen]({guide}) | [Befehle aller registrierten Tools]({table})', '',
              'Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.',
              '', END]
    return '\n'.join(lines)


def update(text, block):
    if START not in text and END not in text:
        return text.rstrip() + '\n\n' + block + '\n'
    if text.count(START) != 1 or text.count(END) != 1 or text.index(START) > text.index(END):
        raise ValueError('Uneindeutige SSH-Abschnittsmarker; keine Datei ueberschrieben')
    start, end = text.index(START), text.index(END) + len(END)
    return text[:start] + block + text[end:]


def coverage(rows, contents):
    result = []
    for row in rows:
        name = row['doc']
        text = contents.get(name, '')
        problems = []
        if not name or not text:
            problems.append('missing-doc')
        else:
            if text.count(START) != 1 or text.count(END) != 1 or text.index(START) > text.index(END):
                problems.append('missing-ssh-section')
            else:
                section = text.split(START, 1)[1].split(END, 1)[0]
                command = 'python3 -I -B scripts/tool_commands.py show ' + row['id']
                if not re.search('^' + re.escape(command) + '$', section, re.M):
                    problems.append('missing-tool-plan')
                if 'ssh -t vps' not in section or 'bash setup_ultimate.sh' not in section:
                    problems.append('missing-ssh-entry')
                if '### SSH-Aktionen: `' + row['id'] + '`' not in section:
                    problems.append('missing-tool-instructions')
        result.append(dict(id=row['id'], doc=name, covered=not problems, problems=problems,
                           unattended=row['unattended']))
    return result


def report(rows):
    complete = sum(row['covered'] for row in rows)
    lines = ['# SSH-Dokumentationsabdeckung aller Tools', '',
             'Generiert aus der vollstaendigen Tool-Registry und ihren verlinkten Anleitungen.',
             'Keine Installation, SSH-Verbindung oder Runtime-Pruefung; kein Produktivnachweis.', '',
             f'**{complete} / {len(rows)} Tool-IDs mit zugeordneter Anleitung, SSH-Einstieg und eigenem Offline-Plan.**', '',
             'Bestehende Sammelanleitungen bleiben erhalten. Neue kurze Einstiegsseiten schliessen',
             'Dokumentationsluecken, ersetzen aber keine fehlende Lifecycle- oder Runtime-Abnahme.',
             'Nur freigegebene native Adapter bekommen direkte Installationsbefehle; ansonsten',
             'gilt der ausdruecklich zu pruefende interaktive SSH-Einstieg mit tool-spezifischen Grenzen.', '',
             '[SSH-Anleitung](../HEADLESS_SETUP.md) | [Befehlstabelle](HEADLESS_TOOL_COMMANDS.md)', '',
             '| Tool-ID | SSH-Anleitung | Dokumentation | Ausfuehrungsweg |',
             '| --- | --- | --- | --- |']
    for row in rows:
        path = os.path.relpath(row['doc'], 'docs/generated').replace('\\', '/') if row['doc'] else None
        link = f'[SSH-Installation]({path}#vps-ueber-ssh-bedienen)' if path else 'Fehlt'
        state = 'abgedeckt' if row['covered'] else ', '.join(row['problems'])
        mode = 'Gepinntes natives Rezept; Einzelfreigabe' if row['unattended'] != 'not-reviewed' else 'Interaktiv/manuell pruefen; kein Headless-Adapter'
        lines.append(f"| {row['id']} | {link} | {state} | {mode} |")
    lines += ['', 'Offline pruefen: `python3 -I -B scripts/quality/tool_ssh_docs.py`.',
              'Abschnitte und Bericht erneuern: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.', '']
    return '\n'.join(lines)


def output_safe(root, name):
    path = root
    for part in Path(name).parts:
        path /= part
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('Verlinktes Ausgabeziel')
    if path.exists() and not path.is_file():
        raise ValueError('Ausgabeziel ist keine Datei')
    return path


def check(root=ROOT, write=False):
    # Validate all destinations and sections before writing any of them.
    changes = []
    records = catalog.catalog(root)
    targets = guides(root, records)
    contents = {}
    for name, related in targets.items():
        path = root / name
        original = path.read_text(encoding='utf-8')
        expected = update(original, render(name, related))
        contents[name] = expected
        if original != expected:
            changes.append((path, expected))
    checked = coverage(records, contents)
    missing = [row for row in checked if not row['covered']]
    if missing:
        print(json.dumps(dict(scope='all-registered-tools', total=len(checked), missing=missing), ensure_ascii=True))
        return 1
    index = output_safe(root, REPORT)
    expected_index = report(checked)
    if not index.is_file() or index.read_text(encoding='utf-8') != expected_index:
        changes.append((index, expected_index))
    if write:
        for path, expected in changes:
            relative = path.relative_to(root).as_posix()
            output_safe(root, relative)
            if relative != REPORT and not catalog.file_in_repo(root, relative):
                raise ValueError('Dokumentationsziel wurde veraendert')
            path.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile('w', encoding='utf-8', newline='\n', dir=path.parent, delete=False) as stream:
                temporary = Path(stream.name)
                stream.write(expected)
            try:
                os.replace(temporary, path)
            finally:
                temporary.unlink(missing_ok=True)
    print(f'SSH-Abdeckung: {len(checked)}/{len(checked)} Tools; Anleitungen: {len(targets)}; '
          f'Abweichungen: {len(changes)}; geschrieben: {write}')
    return int(bool(changes) and not write)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    try:
        return check(write=args.write)
    except (ValueError, OSError, KeyError, TypeError) as error:
        parser.exit(2, 'SSH-Dokumentation abgelehnt: ' + str(error) + '\n')


if __name__ == '__main__':
    raise SystemExit(main())
