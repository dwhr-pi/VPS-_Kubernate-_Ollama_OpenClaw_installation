"""Offline registry monitoring artifacts; never probe, install or start a tool."""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
OUTPUTS = (
    'monitoring/tool-rules.yml',
    'deploy/kustomize/tool-observability/tool-rules.yaml',
    'monitoring/grafana/dashboards/all-tools.json',
    'docs/monitoring/TOOL_COVERAGE.md',
)
IDENTIFIER = re.compile(r'[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}\Z')


def catalog(root=ROOT):
    rows = json.loads((root / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
    ids = [row['id'] for row in rows]
    if len(set(ids)) != len(ids) or not all(IDENTIFIER.fullmatch(key) for key in ids):
        raise ValueError('Invalid or duplicate registry identifiers')
    return sorted(rows, key=lambda row: row['id'])


def textfile(rows, scope='local', expected=()):
    if not IDENTIFIER.fullmatch(scope):
        raise ValueError('Invalid monitoring scope')
    ids = {row['id'] for row in rows}
    if set(expected) - ids:
        raise ValueError('Expected tool is not registered')
    lines = [
        '# HELP openclaw_tool_catalog_count Registry count, not installed tool count.',
        '# TYPE openclaw_tool_catalog_count gauge',
        f'openclaw_tool_catalog_count{{monitoring_scope="{scope}"}} {len(rows)}',
        '# HELP openclaw_tool_info Registry membership only, not runtime acceptance.',
        '# TYPE openclaw_tool_info gauge',
    ]
    for row in rows:
        lines.append(f'openclaw_tool_info{{monitoring_scope="{scope}",tool="{row["id"]}"}} 1')
    lines.extend([
        '# HELP openclaw_tool_monitoring_expected Explicit operator expectation of a scrape target.',
        '# TYPE openclaw_tool_monitoring_expected gauge',
    ])
    for key in sorted(set(expected)):
        lines.append(f'openclaw_tool_monitoring_expected{{monitoring_scope="{scope}",tool="{key}"}} 1')
    return '\n'.join(lines) + '\n'


def alert(name, expr, duration, summary, severity='warning'):
    return {'alert': name, 'expr': expr, 'for': duration,
            'labels': {'severity': severity}, 'annotations': {'summary': summary}}


def groups():
    return [{'name': 'openclaw-tool-targets', 'rules': [
        {'record': 'openclaw:tool_scrape_up:max',
         'expr': 'max by (monitoring_scope, tool) (up{tool!="",monitoring_scope!=""})'},
        alert('OpenClawToolTargetDown', 'up{tool!="",monitoring_scope!=""} == 0', '5m',
              'Tool-Metrikziel {{ $labels.tool }} nicht erreichbar; kein Funktionsnachweis'),
        alert('OpenClawToolExpectedTargetMissing',
              '(max by (monitoring_scope, tool) (openclaw_tool_monitoring_expected) == 1) '
              'unless on (monitoring_scope, tool) openclaw:tool_scrape_up:max', '10m',
              'Freigegebenes Metrikziel {{ $labels.tool }} fehlt in der Discovery'),
        alert('OpenClawToolCatalogMissing',
              '(up{openclaw_tool_catalog="enabled"} == 1) '
              'unless on (job, instance) openclaw_tool_catalog_count', '10m',
              'Textfile-Katalog fehlt trotz erreichbarem, explizit markiertem Collector'),
    ]}, {'name': 'openclaw-tool-kubernetes', 'rules': [
        # Requires an explicit kube-state-metrics pod-label allowlist, not all labels.
        alert('OpenClawToolPodNotReady',
              '((max by (namespace, pod) (kube_pod_status_ready{condition="true"}) == 0) '
              'and on (namespace, pod) '
              '(max by (namespace, pod) (kube_pod_status_phase{phase=~"Pending|Running|Unknown"}) == 1)) '
              '* on (namespace, pod) group_left (label_openclaw_tool) '
              'max by (namespace, pod, label_openclaw_tool) '
              '(kube_pod_labels{label_openclaw_tool!=""})', '10m',
              'Tool-Pod {{ $labels.label_openclaw_tool }} nicht bereit'),
        alert('OpenClawToolPodRestarting',
              '(sum by (namespace, pod) (increase(kube_pod_container_status_restarts_total[15m])) > 3) '
              '* on (namespace, pod) group_left (label_openclaw_tool) '
              'max by (namespace, pod, label_openclaw_tool) '
              '(kube_pod_labels{label_openclaw_tool!=""})', '5m',
              'Tool-Pod {{ $labels.label_openclaw_tool }} startet wiederholt neu'),
    ]}, {'name': 'openclaw-tool-hardware', 'rules': [
        alert('OpenClawGPUHighTemperature', 'DCGM_FI_DEV_GPU_TEMP > 85', '10m',
              'GPU {{ $labels.gpu }} ueber 85 Grad; Hardwaregrenze separat pruefen'),
    ]}]


def dashboard():
    datasource = {'type': 'prometheus', 'uid': '${DS_PROMETHEUS}'}
    panels = [{
        'id': 1, 'type': 'text', 'title': 'Nachweisgrenzen',
        'gridPos': {'x': 0, 'y': 0, 'w': 24, 'h': 4},
        'options': {'mode': 'markdown', 'content':
                    'Alle Registry-Tools sind Katalogeintraege, nicht installiert oder gesund. '
                    'Ein erfolgreicher Scrape ist kein erfolgreicher Tool-Aufruf. '
                    'Fehlende Reihen bedeuten **keine Daten**, nicht Erfolg. '
                    'GPU/Host-Werte sind nicht einzelnen Tools zugeordnet. '
                    'CLI, Desktop und Quellen ohne Exporter bleiben Laufzeit-unbestaetigt.'},
    }]
    entries = [
        ('Alle Tools im Katalog', 'table',
         'max by (monitoring_scope, tool) (openclaw_tool_info{monitoring_scope=~"$scope",tool=~"$tool"})', 'short'),
        ('Explizit erwartete Metrikziele', 'table',
         'max by (monitoring_scope, tool) (openclaw_tool_monitoring_expected{monitoring_scope=~"$scope",tool=~"$tool"})', 'short'),
        ('Scrape-Status je Ziel (nicht Tool-Gesundheit)', 'timeseries',
         'up{monitoring_scope=~"$scope",tool=~"$tool",tool!=""}', 'short'),
        ('Erwartet, aber kein Ziel entdeckt', 'table',
         '(max by (monitoring_scope, tool) (openclaw_tool_monitoring_expected{monitoring_scope=~"$scope",tool=~"$tool"}) == 1) '
         'unless on (monitoring_scope, tool) max by (monitoring_scope, tool) '
         '(up{monitoring_scope=~"$scope",tool=~"$tool",tool!=""})', 'short'),
        ('Scrape-Dauer (keine Inferenzlatenz)', 'timeseries',
         'scrape_duration_seconds{monitoring_scope=~"$scope",tool=~"$tool",tool!=""}', 's'),
        ('Aktive Tool-Alarme', 'table', 'ALERTS{alertname=~"OpenClawTool.*",alertstate="firing"}', 'short'),
        ('Tool-Pods bereit (KSM-Allowlist erforderlich)', 'table',
         'max by (namespace, pod) (kube_pod_status_ready{condition="true"}) '
         '* on (namespace, pod) group_left (label_openclaw_tool) '
         'max by (namespace, pod, label_openclaw_tool) (kube_pod_labels{label_openclaw_tool=~"$tool",label_openclaw_tool!=""})', 'short'),
        ('Host-RAM verfuegbar, alle erfassten Hosts', 'timeseries', 'node_memory_MemAvailable_bytes', 'bytes'),
        ('GPU-VRAM, alle erfassten GPUs (optional)', 'timeseries', 'DCGM_FI_DEV_FB_USED * 1024 * 1024', 'bytes'),
        ('GPU-Temperatur, alle erfassten GPUs (optional)', 'timeseries', 'DCGM_FI_DEV_GPU_TEMP', 'celsius'),
        ('Ollama-Inventar (keine Inferenz)', 'timeseries', 'ollama_monitor_up', 'short'),
    ]
    for i, (title, kind, expr, unit) in enumerate(entries):
        panel = {'id': i + 2, 'title': title, 'type': kind, 'datasource': datasource,
                 'gridPos': {'x': (i % 2) * 12, 'y': 4 + (i // 2) * 8, 'w': 12, 'h': 8},
                 'fieldConfig': {'defaults': {'unit': unit, 'noValue': 'Keine Daten'}, 'overrides': []},
                 'targets': [{'refId': 'A', 'expr': expr, 'instant': kind == 'table',
                              'format': 'table' if kind == 'table' else 'time_series'}]}
        if kind == 'table':
            panel['options'] = {'showHeader': True, 'enablePagination': True}
        panels.append(panel)
    return {
        'uid': 'openclaw-all-tools', 'title': 'OpenClaw: Alle Tools und Monitoring-Abdeckung',
        'schemaVersion': 39, 'version': 1, 'timezone': 'browser', 'refresh': '1m',
        'tags': ['openclaw', 'tools', 'coverage'], 'time': {'from': 'now-1h', 'to': 'now'},
        'templating': {'list': [
            {'name': 'DS_PROMETHEUS', 'type': 'datasource', 'query': 'prometheus',
             'label': 'Prometheus', 'current': {'text': 'prometheus', 'value': 'prometheus'}},
            *[{'name': name, 'type': 'query', 'datasource': datasource,
               'query': query, 'refresh': 1, 'multi': True, 'includeAll': True, 'allValue': '.*',
               'current': {'text': 'All', 'value': '$__all'}} for name, query in (
                   ('scope', 'label_values(openclaw_tool_info, monitoring_scope)'),
                   ('tool', 'label_values(openclaw_tool_info{monitoring_scope=~"$scope"}, tool)'))],
        ]}, 'panels': panels,
    }


def render(root=ROOT):
    rows = catalog(root)
    rules = {'groups': groups()}
    resource = {'apiVersion': 'monitoring.coreos.com/v1', 'kind': 'PrometheusRule',
                'metadata': {'name': 'openclaw-all-tools', 'namespace': 'monitoring',
                             'labels': {'release': 'llmops-monitoring'}}, 'spec': rules}
    lines = ['# Monitoring-Abdeckung aller Tools', '',
             'Generiert aus `config/tools.yml`; nicht manuell bearbeiten.', '',
             f'**{len(rows)} Tools**. Katalogabdeckung ist kein Installations- oder Laufzeitnachweis.',
             'Alarme gelten nur fuer explizit markierte Scrape-Ziele bzw. Pod-Labels.',
             'Ohne Exporter: keine Latenz-, Token-, Fehlerquoten- oder Verfuegbarkeitsbehauptung.', '',
             '[Einrichtung und Grenzen](ALL_TOOLS_OBSERVABILITY.md).', '',
             '| Tool-ID | Tool-Dokumentation | Laufzeit-Monitoring |', '| --- | --- | --- |']
    for row in rows:
        doc = row.get('doc', '')
        link = f'[Anleitung](../../{doc})' if doc and (root / doc).is_file() else 'Nicht zugeordnet'
        lines.append(f'| `{row["id"]}` | {link} | Opt-in Ziel/Pod-Label, Runtime unbestaetigt |')
    dump = lambda value: json.dumps(value, ensure_ascii=True, indent=2) + '\n'
    return dict(zip(OUTPUTS, [dump(rules), dump(resource), dump(dashboard()), '\n'.join(lines) + '\n']))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--write', action='store_true')
    mode.add_argument('--check', action='store_true')
    mode.add_argument('--textfile', action='store_true')
    parser.add_argument('--scope', default='local')
    parser.add_argument('--expect', action='append', default=[])
    args = parser.parse_args(argv)
    try:
        if (args.scope != 'local' or args.expect) and not args.textfile:
            raise ValueError('Scope/expect require textfile mode')
        if args.textfile:
            print(textfile(catalog(), args.scope, args.expect), end='')
        elif args.check or args.write:
            for name, content in render().items():
                path = ROOT / name
                if args.write:
                    if path.is_symlink():
                        raise ValueError('Refusing linked output')
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text(content, encoding='utf-8', newline='\n')
                elif not path.is_file() or path.read_text(encoding='utf-8') != content:
                    print('Monitoring artifacts differ: ' + name, file=sys.stderr)
                    return 1
            print('Tool monitoring artifacts synchronized; no runtime acceptance.')
        else:
            print('Offline plan: --check, --write repository artifacts, or --textfile to stdout. No service/probe.')
        return 0
    except (OSError, ValueError, KeyError):
        print('Tool monitoring generation refused; check registry and arguments.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
