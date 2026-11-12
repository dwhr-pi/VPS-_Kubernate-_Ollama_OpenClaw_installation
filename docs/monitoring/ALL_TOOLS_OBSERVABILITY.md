# Prometheus und Grafana fuer alle Tools

Fuer die grafische Tool-/Kubernetes-Auswahl zuerst den
[Browser-/Desktop-Dashboard-Einstieg](../TOOL_DASHBOARD_BROWSER_DESKTOP.md) lesen.
Headlamp zeigt Cluster-Ressourcen; diese Seite behandelt die davon getrennten Grafana-Messwerte.

Stand: 2026-11-12. Dieses Paket ergaenzt das vorhandene Monitoring **opt-in**.
Keine Installation, kein Dienststart, kein Kubernetes-Apply und keine Inferenz werden automatisch ausgefuehrt.
Die Git-Source-Installationsrichtlinie gilt unveraendert; keine Docker-/Compose-Installation.

Die uebergreifende Reihenfolge steht im
[Arbeitsplan E01-E09](../architecture/ENTERPRISE_HARDENING_ROADMAP.md):
Metrics-Zugang zuerst absichern, dann Inferenz-SLOs und Tracing abnehmen; Autoscaling bleibt ein spaeterer Schritt.

## Was abgedeckt ist

Der [vollstaendige Katalog](TOOL_COVERAGE.md) umfasst alle IDs der Haupt-Registry `config/tools.yml`.
Neue Eintraege werden beim Regenerieren automatisch aufgenommen. Es gibt kein erfundenes `/metrics` pro Tool.
Auch geplante, reine Quellen-, CLI-, Android- und Desktop-Tools bleiben sichtbar, aber **Runtime unbestaetigt**.
Die Kategorie und der Name allein belegen keinen Metrikvertrag.

| Ebene | Signal | Aussage und Grenze |
| --- | --- | --- |
| Alle Registry-Tools | `openclaw_tool_info` | Katalogeintrag, weder installiert noch gestartet |
| Bewusst erwartete Ziele | `openclaw_tool_monitoring_expected` | Betreiber erwartet Discovery, kein Erfolgssignal |
| Freigegebene Exporter | `up`, `scrape_duration_seconds` | Erreichbarkeit und Scrape-Dauer, keine Tool-/Inferenzgesundheit |
| Markierte Kubernetes-Pods | kube-state-metrics | Readiness und Neustarts, kein erfolgreicher Agentenlauf |
| Hosts | Node Exporter | Vorhandene RAM-/Dateisystem-/CPU-Metriken, nicht pro Tool attribuiert |
| GPUs | DCGM Exporter | Framebuffer und Temperatur, nicht automatisch pro Tool attribuiert |
| Ollama | Vorhandener Read-only-Exporter | Modellinventar, keine Inferenzlatenz oder Tokenrate |

Bestehende Gateway-, RAM-, Disk-, Inventar- und GPU-Druckregeln bleiben erhalten.
Die neuen sechs Alarme plus eine Recording Rule ergaenzen sie. Generische Scrape-Ausfaelle koennen
parallel zum Tool-Alarm melden; Alertmanager-Routen/Inhibitionen bewusst abstimmen, nicht pauschal stummschalten.
Latenz-, Token-, Kosten-, Qualitaets- und Fehlerquotenalarme brauchen erst einen belegten Tool-Metrikvertrag.
Unueberwachte Tools erzeugen keine pauschalen Ausfallalarme. Fehlende Daten werden nicht als Null/Erfolg aufgefuellt.

| Neuer Alarm | Bedingung | Mindestdauer |
| --- | --- | --- |
| `OpenClawToolTargetDown` | Markierter Scrape liefert `up=0` | 5 Minuten |
| `OpenClawToolExpectedTargetMissing` | Explizite Erwartung ohne Ziel im gleichen Scope | 10 Minuten |
| `OpenClawToolCatalogMissing` | Markierter Collector erreichbar, Katalog fehlt | 10 Minuten |
| `OpenClawToolPodNotReady` | Markierter aktiver Pod nicht bereit | 10 Minuten |
| `OpenClawToolPodRestarting` | Mehr als drei Neustarts in 15 Minuten | 5 Minuten |
| `OpenClawGPUHighTemperature` | DCGM-Temperatur ueber 85 Grad | 10 Minuten |

Die Recording Rule `openclaw:tool_scrape_up:max` aggregiert je Scope und Tool.
Der TargetDown-Alarm bleibt pro Ziel: ein ausgefallenes Replikat wird nicht durch ein gesundes verdeckt.

## Artefakte und Offline-Pruefung

- [Grafana-Dashboard JSON](../../monitoring/grafana/dashboards/all-tools.json): alle Tools, Scope-/Tool-Filter,
  erwartete und fehlende Ziele, Scrape-Status und getrennte optionale Hardwareansichten.
- [Native Regeln](../../monitoring/tool-rules.yml): YAML-kompatibles JSON fuer Prometheus.
- [PrometheusRule](../../deploy/kustomize/tool-observability/tool-rules.yaml): identische Gruppen fuer den Operator.
- [Generator](../../scripts/monitoring/tool_observability.py): liest nur den Repository-Katalog, keine Benutzerdateien.
- [Promtool-Fixtures](../../tests/fixtures/tool-observability.rules.test.yml): fehlend, down, healthy, unueberwacht.

```bash
python3 -I -B scripts/monitoring/tool_observability.py
python3 -I -B scripts/monitoring/tool_observability.py --check
python3 -B -m unittest discover -s tests -p 'test_tool_observability.py' -v
```

Nach Registry-Aenderungen: `python3 -I -B scripts/monitoring/tool_observability.py --write`.
Das schreibt nur die vier oben verknuepften Repository-Artefakte, keine private Prometheus-Konfiguration.
Die Offline-Regression prueft den Drift automatisch mit.

Mit einem separat geprueften, nativ gebauten `promtool` (kein automatischer Download):

```bash
promtool check rules monitoring/tool-rules.yml
promtool test rules tests/fixtures/tool-observability.rules.test.yml
```

Strukturelle Python-Tests ersetzen weder die PromQL-Auswertung mit promtool noch die echte Zielsystem-Abnahme.

## Katalog als Textfile exportieren

Der vorhandene Node Exporter muss den Textfile-Collector mit einem dedizierten Verzeichnis verwenden.
Das Verzeichnis muss vom Exporter lesbar und nur vom Monitoring-Verwalter beschreibbar sein.
Nicht das gesamte Home-Verzeichnis mounten oder freigeben. Keine Tokens, Prompts, Pfade oder Audiodaten exportieren.
Ein Katalogexport pro Scope reicht; keine Kopie auf jeden Worker verteilen.

Zuerst rein lokal ansehen, ohne Dateien anzulegen:

```bash
python3 -I -B scripts/monitoring/tool_observability.py --textfile --scope home
```

Erst nach separater Exporter-Einrichtung bewusst publizieren (Beispielpfad vorher anlegen und Rechte pruefen):

```bash
(
  set -euo pipefail
  dir='/var/lib/node_exporter/textfile_collector'
  test -d "$dir" && test -w "$dir"
  tmp=$(mktemp "$dir/.openclaw-tools.XXXXXXXX")
  trap 'rm -f -- "$tmp"' EXIT
  python3 -I -B scripts/monitoring/tool_observability.py --textfile --scope home > "$tmp"
  chmod 0644 "$tmp"
  mv -f -- "$tmp" "$dir/openclaw-tools.prom"
)
```

Dies ersetzt nur den eigenen Katalog-Snapshot, keine Nutzerdaten; kein Cronjob und kein Reload werden eingerichtet.
Der Collector liest `*.prom`; die temporaere Datei endet absichtlich nicht so. Fuer mehrere Standorte
eindeutige Scopes nutzen, etwa `home` und `vps`. Scope/IDs akzeptieren nur begrenzte sichere Zeichen.
Nach Registry-Aenderungen oder Aenderungen erwarteter Ziele den Snapshot bewusst erneut publizieren.

Erwartungen erst nach Exporter-/Auth-/Firewall-Abnahme setzen, z. B. zusaetzlich `--expect ollama`.
Das erwartet ausschliesslich ein markiertes **Metrikziel**, keinen Modellstart und keine Inferenz.
Ohne `--expect` ist kein Tool als laufend vorausgesetzt. Ein pausierter WoL-Worker sollte nicht als erwartet gelten.

## Native Prometheus-Anbindung

Die private Konfiguration um diese Regeldatei ergaenzen; bestehende Regeln nicht entfernen:

```yaml
rule_files:
  - /absoluter/repository-pfad/monitoring/alerts.yml
  - /absoluter/repository-pfad/monitoring/tool-rules.yml
```

Alternativ unterstuetzt der vorhandene private Konfigurationsgenerator
`scripts/security/native_monitoring_config.py` den optionalen Schalter `--tool-rules`.
Seine bisherigen Freigaben, privaten Zieladressen und Secret-Dateien bleiben erforderlich.
Ohne den Schalter bleibt das bisherige Verhalten erhalten.

Am bestehenden, freigegebenen Node-Exporter-Target das Label `openclaw_tool_catalog: enabled` setzen:

```yaml
scrape_configs:
  - job_name: node
    static_configs:
      - targets: ['127.0.0.1:9100']
        labels:
          openclaw_tool_catalog: enabled
```

Dieses Label aktiviert die Erkennung eines fehlenden Katalogs. Es ist kein neues zusaetzliches Scrape-Ziel.
Am bestehenden Tool-Exporter-Target die exakte Registry-ID und den Scope setzen, z. B.:

```yaml
static_configs:
  - targets: ['127.0.0.1:9404']
    labels:
      tool: ollama
      monitoring_scope: home
```

Port 9404 gehoert hier zum vorhandenen Ollama-Inventarexporter, **nicht** zur Ollama-API.
Fuer andere Tools zuerst den jeweiligen Exporter und dessen privaten Port pruefen; nicht blind kopieren.
Das Node-Target darf nicht ebenfalls `tool` oder `monitoring_scope` bekommen: sonst benennt Prometheus
die gleichnamigen Textfile-Labels um. Keine doppelten Scrapes und keine unbegrenzten Label-Werte erzeugen.
Auth/TLS und Secret-Dateireferenzen bestehender Jobs erhalten. Keine oeffentlichen API-Scans aktivieren.

## Kubernetes und Grafana

Das separate Overlay ist nicht in der Basis enthalten. Voraussetzungen: existierender Namespace `monitoring`,
Prometheus Operator samt CRDs und passende `ruleSelector`/`ruleNamespaceSelector`.
Es verwendet wie die vorhandenen Values das Label `release: llmops-monitoring`.

```bash
kubectl kustomize deploy/kustomize/tool-observability
```

Nur rendern, nicht automatisch anwenden. Spaeter bewusst freigeben; keine zweite Installation des Monitorings.
Fuer Pod-Alarme Pods mit `openclaw_tool: <exakte-registry-id>` beschriften und in kube-state-metrics nur
dieses Label freigeben, beispielsweise per Helm-Values:

```yaml
kube-state-metrics:
  metricLabelsAllowlist:
    - pods=[openclaw_tool]
```

Abgeschlossene Jobs (`Succeeded`/`Failed`) werden vom Readiness-Alarm nicht als laufende Dienste behandelt.
Job-Fehler und Ausfuehrungsfristen benoetigen einen separaten, fachlich passenden Batch-Vertrag.

Diese Pod-Regeln sind fuer einen Cluster pro Prometheus gedacht. Fuer ein Multi-Cluster-Aggregat vor Aktivierung
einen eindeutigen Cluster-Labelvertrag in allen Aggregationen und Joins ergaenzen.
GPU-Temperatur von 85 Grad ist ein konservativer Startwert, kein universeller Herstellerschwellwert.
Die Abnahme muss Hardwaregrenzen, DCGM-Sentinelwerte und erlaubte Zielmenge pruefen.

In Grafana **Dashboards > Import** das JSON waehlen, danach die Variable `Prometheus` auf die richtige
Datenquelle einstellen. Bestehende UID `openclaw-all-tools` beim erneuten Import aktualisieren.
Datei-Provisioning ist ebenfalls moeglich: die vorhandene Dashboard-Provisionierung liest denselben Ordner.
Eine leere Scope-/Tool-Auswahl bedeutet, dass der Textfile-Katalog noch nicht gescrapt wird.
Hardware-/Ollama-Ansichten sind bewusst global, nicht durch den Tool-Filter attribuiert; ihre Titel weisen darauf hin.

## Abnahme und Rueckbau

1. Offline-Checks und promtool ausfuehren; private Konfiguration mit `promtool check config` pruefen.
2. Scrape-/Rule-Auswahl und Kataloganzahl gegen die Registry vergleichen; unbekannte Ziele untersuchen.
3. In isolierter Testumgebung ein explizites Ziel entfernen: Missing-Alarm nach zehn Minuten pruefen.
4. Ein vorhandenes Testziel unerreichbar machen: TargetDown nach fuenf Minuten pruefen, nicht Missing.
5. Ohne Erwartung und ohne Exporter darf ein Quellen-/CLI-Tool keine Stoerung ausloesen.
6. Benachrichtigungen erst separat freigeben; keine Discord-/Provider-Tests durch diesen Generator.

Rueckbau: nur die neue Regeldateireferenz bzw. das optionale Rule-Objekt und den eigenen Textfile-Snapshot
entfernen; bestehende Regeln und Benutzerdaten behalten. Der Snapshot wird nicht automatisch geloescht.
Noch offen: reale Grafana-Importpruefung, promtool-Auswertung, Zielsystem-Scrapes, Alarmzustellung und
individuelle Fachmetriken fuer Tools ohne belegten Exporter.

## Primaerquellen

- [Prometheus: Recording Rules und Offline-Syntaxpruefung](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
- [Prometheus: Unit-Tests fuer Regeln](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/)
- [Node Exporter: Textfile-Collector](https://github.com/prometheus/node_exporter#textfile-collector)
- [Grafana: JSON-Dashboardmodell](https://grafana.com/docs/grafana/latest/visualizations/dashboards/build-dashboards/view-dashboard-json-model/)
