"""Render a dated, conservative tool inventory without executing registry commands."""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = 'docs/TOOL-MATRIX-NEU.md'
K8S = {
    'ollama': 'k8s/base/ollama.yml',
    'openclaw': 'k8s/platform/openclaw-hardening-patch.yml',
    'open_webui': 'deploy/kustomize/optional/open-webui/workload.yaml',
    'qdrant': 'k8s/gitops/memory/qdrant.yaml',
    'litellm': 'k8s/base/litellm.yml',
}
PROBES = {'ollama': 'ollama', 'openclaw': 'openclaw', 'open_webui': 'open-webui',
          'litellm': 'inference-gateway', 'n8n': 'n8n'}


def audit_status(row, root):
    # A structural contract is necessary, not sufficient for runtime acceptance.
    if row['id'] in ('openhands', 'watchtower'):
        return 'WIDERSPRUCH'
    installer = row.get('install_script', '')
    if not installer or not (root / installer).is_file() or installer.endswith('planned_tool_stub_install.sh'):
        return 'DOKU-ONLY'
    return 'STUB'


def cell(value):
    return str(value).replace('|', '&#124;').replace('\n', ' ').replace('\r', ' ').replace('`', '')


def render(root=ROOT):
    rows = json.loads((root / 'config/tools.yml').read_text(encoding='utf-8'))['tools']

    def link(path):
        if not path:
            return 'nicht eingetragen'
        if not (root / path.split('#')[0]).is_file():
            return 'Pfad fehlt: ' + cell(path)
        return '[Datei](../' + path + ')'

    lines = [
        '# Tool-Wahrheitstabelle: Review 2026-11-11', '',
        'Quelle: Haupt-Registry `config/tools.yml`. Erzeugt durch',
        '`python3 -I -B scripts/quality/tool_truth_table.py --check`; nicht manuell bearbeiten.', '',
        f'Inventar: **{len(rows)} Tools**. Datei vorhanden bedeutet weder installierbar noch installiert.',
        'Kein Tool wird durch diese Offline-Inventur als laufende Runtime oder stabil abgenommen.', '',
        'Status ist die unveraenderte Registry-Angabe. Auch `stable` ist kein Testnachweis.',
        'Auditstatus separat: STUB = unvollstaendiger oder nicht runtime-abgenommener Integrationsvertrag,',
        'nicht die Behauptung, das Upstream-Programm sei ein Stub. DOKU-ONLY = kein individueller Installer belegt.',
        'WIDERSPRUCH = optionaler Workbench-Pfad oder Docker-API-Verbrauch kollidiert mit diesem Auftrag.',
        'VERIFIZIERT erfordert Installer + Runtime-Definition + Smoke plus echten Laufzeitnachweis.',
        'Kein Tool wird hier VERIFIZIERT oder TOT genannt. Bewertung: [Audit](AUDIT-2026-11-11.md).',
        'Installer/Doctor/Update/Uninstall: nur Existenz des eingetragenen Pfades.',
        'Nicht zugeordnet bedeutet nicht, dass im restlichen Repository kein Manifest existiert.',
        'OpenClaw-Manifeste sind Patches; Open WebUI ist standardmaessig deaktiviert.',
        'Bekannte native Rezept-Wrapper koennen bewusst sperren: siehe [Buildvertraege](DOCKER_TO_GITHUB.md).', '',
        'Smoke-Spalte: ein begrenzter Endpunkt ist implementiert, aber hier **nicht am Zielsystem getestet**.',
        'Alle anderen Tools: kein zentral zugeordneter Runtime-Probe, also **nicht verifiziert**,',
        'nicht pauschal echt oder fehlt. Einzelne Wrapper wurden nicht alle semantisch abgenommen.',
        'Pruefumfang und Nachweisgrenzen: [Review](REVIEW-2026-11-11.md).', '',
        '| Tool | Installer | systemd/K8s-Zuordnung | Smoke (offen) | Doku | Auditstatus | Registry-Status | Doctor | Update | Uninstall |',
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |']
    for row in sorted(rows, key=lambda row: row['id']):
        probe = PROBES.get(row['id'])
        smoke = f'`--require {probe}`' if probe else 'nicht zugeordnet'
        lines.append('| ' + ' | '.join([
            cell(row['id']), link(row.get('install_script')),
            link(K8S.get(row['id'])) if row['id'] in K8S else 'nicht zugeordnet',
            smoke, link(row.get('doc')), audit_status(row, root),
            cell(row.get('status', 'nicht angegeben')), link(row.get('doctor_script')),
            link(row.get('update_script')), link(row.get('uninstall_script'))]) + ' |')
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    expected = render()
    path = ROOT / OUTPUT
    if args.check:
        if not path.is_file() or path.read_text(encoding='utf-8') != expected:
            print('Tool-Wahrheitstabelle ist nicht synchron.', file=sys.stderr)
            return 1
        print('Tool-Wahrheitstabelle synchron; keine Runtime-Abnahme.')
        return 0
    print(expected, end='')
    return 0


if __name__ == '__main__':
    sys.exit(main())
