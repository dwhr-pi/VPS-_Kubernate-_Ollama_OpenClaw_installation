"""Static tracked-source evidence only: no installers, private files or source snippets in reports."""
import argparse
import ast
from collections import Counter
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OUTPUTS = (
    'docs/generated/AUDIT_SOURCE_LOCATIONS_2026_11_11.md',
    'docs/generated/AUDIT_TEST_INVENTORY_2026_11_11.md',
    'docs/generated/AUDIT_REFERENCE_CANDIDATES_2026_11_11.md',
)
SCOPES = ('scripts/', 'tools/', 'examples/', 'systemd/', 'k8s/', 'deploy/', 'stacks/',
          'profiles/', 'config/', 'configs/', '.github/', 'services/', 'charts/')
EXTENSIONS = {'.py', '.sh', '.yml', '.yaml', '.json', '.toml', '.service', '.timer',
              '.example', '.template', '.conf', '.cfg', '.js', '.ts', '.txt', '.md', '.bats',
              '.mjs', '.cjs', '.tsx', '.jsx', '.ini'}
PATTERNS = {
    'Bewegliches Wort latest/main/master (lexikalisch)': r'(?<![\w-])(?:latest|main|master)(?![\w-])',
    'Git-Clone (Pin kann separat folgen)': r'\bgit\b[^\n]*\bclone\b',
    'Paketinstallation (Lockfile separat pruefen)': r'\b(?:pip3?|npm|pnpm|apt(?:-get)?)\s+(?:install|ci|add)\b',
    'Netz-/Port-Kandidat': r'0\.0\.0\.0|\[::\]|\bNodePort\b|\bLoadBalancer\b|\bhostPort\b|^\s*ports\s*:|\b(?:bind|listen|address)\b',
    'Privilegien-/Host-Kandidat': r'\bsudo\b|\bprivileged\b|\bhostPath\b|\bhostNetwork\b|\brunAsUser\b|\bUser=root\b|\bCapabilities\b|\bcapabilities\b',
    'Ressourcen-/Persistenz-Kandidat': r'\bResourceQuota\b|\bLimitRange\b|\bPodDisruptionBudget\b|\bstorageClassName\b|\bPersistentVolumeClaim\b|\bnvidia\.com/gpu\b',
}


def tracked_files(root):
    # Git's tracked index excludes ignored private workspaces and credentials.
    result = subprocess.run(['git', 'ls-files', '-z'], cwd=root, check=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=20)
    return sorted(set(result.stdout.decode('utf-8').rstrip('\0').split('\0')) - {''})


def public_source(path):
    name = path.name.lower()
    if (name == '.env' or name.endswith(('.key', '.pem', '.p12', '.kubeconfig'))
            or '.env.' in name and not name.endswith(('.example', '.template'))):
        return False
    return True


def read_tracked(root, name):
    relative = Path(name)
    if relative.is_absolute() or '..' in relative.parts:
        raise ValueError('Unsafe tracked path')
    path = root / relative
    for part in (path, *path.parents):
        if part.is_symlink() or (hasattr(part, 'is_junction') and part.is_junction()):
            return None
        if part == root:
            break
    if not public_source(path) or not path.is_file() or path.stat().st_size > 4 * 1024**2:
        return None
    raw = path.read_bytes()
    if b'\0' in raw:
        return None
    return raw.decode('utf-8-sig', errors='replace')


def render(root=ROOT, files=None):
    root = Path(root)
    files = tracked_files(root) if files is None else sorted(files)
    texts = {}
    skipped = []
    for name in files:
        if name in OUTPUTS:
            continue
        path = Path(name)
        if not (path.suffix.lower() in EXTENSIONS or name in (
                'install.sh', 'setup_ultimate.sh', 'verify_and_install.sh', 'verify_release_and_install.sh')
                or path.name in ('Dockerfile', 'Containerfile', 'Makefile')):
            continue
        text = read_tracked(root, name)
        if text is None:
            skipped.append(name)
        else:
            texts[name] = text
    source = ['# Statische Quellfundstellen: 2026-11-11', '',
              'Index getrackter Textdateien; keine Quellzeilen oder Secret-Werte werden ausgegeben.',
              'Basis-Code: c09c829b991dde4033f52e5bce668367e478ea3b plus Review-Patch dieses Branches.',
              'Ausfuehrbare Quellen/Konfigurationen und Beispiele sind getrennt von Aussagen ueber aktive Dienste.',
              'Tests und historische Dokumente sind nicht Teil der nachstehenden Mustergruppen.',
              'Treffer sind **nicht verifiziert**: ein Wort, Kommentar, deny-Wert oder Pin-Checker ist kein Befund.',
              'Separate Checkout-/Hash-Schritte und Lockfiles koennen einen Clone/Paketaufruf absichern.',
              'Kein YAML-Parser, kein Beweis fuer effektive Netzfreigabe, keine transitive SBOM.',
              'Keine Suche in Git-History, privaten Daten, WSL oder laufenden Diensten.', '',
              'Regenerieren/checken: `python3 -I -B scripts/quality/evidence_inventory.py --check`.',
              'Neue Dateien muessen vor der Regeneration im Git-Index stehen.', '']
    for category, pattern in PATTERNS.items():
        matches = []
        for name, text in sorted(texts.items()):
            if not (name.startswith(SCOPES) or name in ('install.sh', 'setup_ultimate.sh',
                    'verify_and_install.sh', 'verify_release_and_install.sh')):
                continue
            if Path(name).suffix.lower() == '.md':
                continue
            for number, line in enumerate(text.splitlines(), 1):
                if re.search(pattern, line, re.IGNORECASE):
                    matches.append(f'- `{name}:{number}`')
        source += ['## ' + category, '', f'{len(matches)} Fundstellen, keine automatische Risikoeinstufung.', '', *matches, '']
    env_files = [name for name in files if '.env' in Path(name).name or '.env.' in name]
    source += ['## Getrackte ENV-Pfade (nur Dateinamen)', '',
               'Beispiele/Templates sind keine bestaetigten Zugangsdaten. Sonstige ENV-Dateien werden nicht gelesen.', '']
    source += [f'- `{name}`' for name in env_files] + ['']
    source += ['## Uebersprungene Text-/Linkpfade', '',
               'Links/Junctions, nicht lesbare oder uebergrosse Dateien nicht als geprueft ausgeben.', '']
    source += [f'- `{name}`' for name in skipped] or ['- Keine.']

    tests = ['# Statisches Testinventar: 2026-11-11', '',
             'Jeder benannte Python-Test und Bats-Fall mit Quellposition; keine Tests werden ausgefuehrt.',
             'Pruefzweck wird durch den vorhandenen Testnamen identifiziert, nicht durch vermutete Runtime-Eigenschaften.',
             'Mock-/Fixture- und Laufzeitsemantik muessen am jeweiligen Quelltext geprueft werden.',
             'Keine Test-Payloads, Schluesselwerte oder Quelldatei-Inhalte im Bericht.',
             'Parametrisierung und dynamisch erzeugte Tests koennen mehr Laufzeitfaelle liefern als statische Namen.', '']
    test_count = 0
    for name, text in sorted(texts.items()):
        if not name.startswith('tests/'):
            continue
        entries = []
        if name.endswith('.py'):
            try:
                tree = ast.parse(text)
            except SyntaxError:
                entries.append(f'- `{name}`: Syntax statisch nicht auswertbar; nicht verifiziert.')
            else:
                for item in ast.walk(tree):
                    if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef)) and item.name.startswith('test_'):
                        entries.append(f'- `{name}:{item.lineno}`\n  Prueffall: `{item.name}`')
        elif name.endswith('.bats'):
            for number, line in enumerate(text.splitlines(), 1):
                if re.match(r'^\s*@test\b', line):
                    entries.append(f'- `{name}:{number}` - Bats-Fall; Pruefzweck im Testtitel der Quelle.')
        if entries:
            tests += ['## ' + name, '', *entries, '']
            test_count += len(entries)
    tests += [f'Statisch benannte Testpositionen: **{test_count}**. Kein Nachweis bestandener Tests.', '']

    # Basename references are deliberately only candidates, never proof of dead code.
    references = Counter()
    basenames = {Path(name).name for name in texts if name.startswith(('tools/', 'scripts/', 'examples/'))}
    for name, text in texts.items():
        tokens = set(re.findall(r'[A-Za-z0-9_.-]+', text))
        for token in tokens & basenames:
            if token != Path(name).name:
                references[token] += 1
    candidates = [name for name in texts if name.startswith(('tools/', 'scripts/', 'examples/'))
                  and references[Path(name).name] == 0]
    extra_installers = []
    import json
    registry = json.loads(texts.get('config/tools.yml', '{"tools":[]}'))['tools']
    registered = {row.get('install_script') for row in registry}
    for name in files:
        if name.startswith('scripts/tools/') and name.endswith('_install.sh') and name not in registered:
            extra_installers.append(name)
    refs = ['# Referenz- und zusaetzliche Integrationskandidaten: 2026-11-11', '',
            'Nicht verifiziert. Fehlende lexikalische Basename-Referenz ist **kein Beweis fuer toten Code**.',
            'Dynamische Menues, externe Aufrufe, gleichnamige Dateien und Profilzuordnung separat pruefen.',
            'Keine automatische Loeschung oder Deprecation aus diesem Index.', '',
            '## Installer ausserhalb direkter Haupt-Registry-Zuordnung', '',
            'Koennen gemeinsame Helper, Aliase oder profilgebundene Tools sein; keine neue Tool-Erfindung.', '']
    refs += [f'- `{name}`' for name in extra_installers] or ['- Keine.']
    refs += ['', '## Deployment-/Profilverzeichnisse', '',
             'Jedes getrackte Unterverzeichnis wird erfasst; ein Verzeichnis kann mehrere Tools buendeln.', '']
    directories = sorted({str(Path(name).parent).replace('\\', '/') for name in files
                          if name.startswith(('stacks/', 'k8s/', 'deploy/kustomize/', 'profiles/'))})
    refs += [f'- `{name}/`' for name in directories]
    refs += ['', '## Ohne nachgewiesene externe Basename-Referenz', '',
             'Nur Nachpruefkandidaten; Status TOT wird fuer keinen dieser Pfade behauptet.', '']
    refs += [f'- `{name}`' for name in candidates] or ['- Keine.']
    return {OUTPUTS[0]: '\n'.join(source).rstrip() + '\n', OUTPUTS[1]: '\n'.join(tests).rstrip() + '\n',
            OUTPUTS[2]: '\n'.join(refs).rstrip() + '\n'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--document', choices=OUTPUTS)
    args = parser.parse_args()
    try:
        outputs = render()
        if args.check:
            drift = [name for name, value in outputs.items()
                     if not (ROOT / name).is_file() or (ROOT / name).read_text(encoding='utf-8') != value]
            if drift:
                print('Audit-Inventare nicht synchron: ' + ', '.join(drift), file=sys.stderr)
                return 1
            print('Statische Audit-Inventare synchron; keine Runtime-Abnahme.')
        elif args.document:
            print(outputs[args.document], end='')
        else:
            parser.error('--check oder --document erforderlich')
        return 0
    except (OSError, ValueError, subprocess.SubprocessError):
        print('Audit-Inventar nicht vollstaendig erzeugbar; keine Abnahme.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
