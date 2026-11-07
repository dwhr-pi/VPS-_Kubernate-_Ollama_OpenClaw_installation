# Infrastruktur- und Tooling-Review

Stand: 07.11.2026. Lokale Basis `a600be21262d4d8b1b65b7a2a313c73abf8b9525`,
Arbeitsbaum zu Beginn sauber. Selektiver Code-/Konfigurationsreview, **kein
vollstaendiger Review aller 402 Tool-Installer** und keine Produktionsfreigabe.
Keine echten Secrets, WSL-/Cluster-/Hostzustaende oder Benutzerdaten gelesen.
Keine Installation, Inferenz, Modellaktion, Dienststart oder Anwendung von YAML.

## Befunde nach Dimension

| Prioritaet | Dimension / Beleg | Bewertung und naechster Schritt |
|---|---|---|
| P1 | Performance: [Ollama](../k8s/base/ollama.yml) | Queue 16, Parallelitaet 1, Kontext 4096 und ein geladenes Modell begrenzen die Last bereits. CPU-Basis fordert 2 GiB RAM und erlaubt 8 GiB: fuer kleine Gratis-VPS nicht unveraendert einsetzen. Eigene Overlays nach Messung dimensionieren, GPU-Inferenz zuhause statt auf CPU-Control-VPS. |
| P1 | Storage: [StatefulSet/PVC](../k8s/base/ollama.yml), [Velero](../k8s/platform/velero/backup-storage-location.yaml) | RWO und Retain erhalten Daten bei Pod-/STS-Loeschung, garantieren aber keine Wiederherstellung nach Nodeverlust. Local-path ist kein verteilter Speicher. Modelle und nicht reproduzierbare Agenten-/Memory-Daten getrennt sichern; Dateisystem-/DB-/PVC-Restore isoliert nachweisen. |
| P1 | Observability: [Exporter](../scripts/monitoring/ollama_readonly_exporter.py), [Regeln](../monitoring/alerts.yml) | Exporter kann HTTP 200 liefern, obwohl Ollama nicht erreichbar ist. Nur `up == 0` erkennt das nicht. Patch 1 ergaenzt `ollama_monitor_up == 0`; Inventar-Pollzeit wird weiterhin nicht als Inferenzlatenz ausgegeben. |
| P1 | Secrets: [native Gateway-Konfiguration](../services/inference-gateway/config.yaml), [Kubernetes-Gateway](../k8s/base/litellm.yml) | K8s-Metriken verlangen bereits Auth; native Gateway-Vorlagen bisher nicht explizit. Patch 1 synchronisiert dies. Secrets bleiben ausserhalb Git; die Zustellung/Rotation und wirksame Berechtigungen sind separat abzunehmen. |
| P1 | Legacy: [Compose-Altstack](../stacks/llmops-platform/docker-compose.yml) | Bewegliche Tags, gemeinsame `.env` und Redis-Passwort in argv bleiben Altlasten. Loopback-Bindings sind vorhanden, ersetzen aber weder dienstweise Secrets noch Sandbox. Nicht neu installieren oder automatisch migrieren; native Git-Builds bevorzugen. |
| P1 | Agenten/MCP: [Workbench](../scripts/agents/workbench.py), [Audio-MCP](../scripts/audio/mcp_audio_server.py) | Rollen-JSON ist keine Sandbox. Workbench besitzt eigene Laufzeitgrenzen, verwendet aber einen separaten Containerpfad; daraus folgt keine Docker-Freigabe. Patch 2 ist ein enger nativer read-only Einstieg, kein allgemeiner Agenten- oder Filesystem-Sandbox-Ersatz. |
| P2 | Resilienz: [Model Broker](../scripts/agents/model_broker.py) | Lokale Inventar-Vorpruefung hatte keinen Backoff. Patch 3 wiederholt nur diesen GET bei klar begrenzten transienten Fehlern. Inferenz-POSTs, Toolwrites und Cloud-Fallback bleiben ohne automatische Wiederholung. |
| P1 | Netzwerk: [Policies](../k8s/base/network-policy.yml), [Exporter-Policy](../k8s/platform/ollama-exporter.yaml) | Default-Deny, private Services und gezielte Scrape-Regeln sind vorhanden. Traefik-Namespace/Labels, CNI-Enforcement und WireGuard-Routen muessen im Zielcluster passen. K3s-Traefik in kube-system passt nicht automatisch zum separaten traefik-Namespace. Negative Verbindungstests bleiben Pflicht. |

Ollama, LiteLLM, Qdrant, SearXNG und OpenTelemetry sind schon im Katalog.
vLLM, Cosign und Headscale sind als geplant verzeichnet, nicht als fehlende
Neuentdeckung oder getestete Runtime ausgeben. Die historischen Statusberichte
sind keine aktuellen Installations-/Runtime-Nachweise.

`OLLAMA_KEEP_ALIVE=5m` ist eine Haltezeit, keine dynamische VRAM-Verhandlung
zwischen Ollama, ComfyUI und anderen GPU-Jobs. Ein gemeinsames gemessenes
GPU-Jobbudget und eine Warteschlange sind vor parallelem Betrieb wichtiger als
ein weiterer Inferenzserver. vLLM/HPA ohne freie GPU-Kapazitaet loesen das nicht.

## Patch 1: Backend-Metriken statt Scheingesundheit

Dieselbe Regel liegt jetzt in der nativen Prometheus-Datei, im kleinen Helmchart
und in der optionalen PrometheusRule. Sie wird nur wirksam, wenn die jeweilige
Konfiguration bewusst geladen wird und ein Exporterziel eingerichtet ist:

```yaml
- alert: OllamaInventoryUnavailable
  expr: ollama_monitor_up == 0
  for: 5m
  labels: {severity: warning}
  annotations:
    summary: Ollama-Inventarabfrage fehlgeschlagen
```

Kein pauschales `absent()`-Alert fuer den standardmaessig abgeschalteten Exporter.
Exporter-Deployment bleibt bei null Replikaten, Ziellisten bleiben unveraendert.
[ServiceMonitor und Regeln](../k8s/monitoring/runtime-observability.yml) passen zu
den vorhandenen Service-Labels. Native Prometheus-Scrapes verwenden den privaten
Bearer-Token-Dateipfad in [prometheus.yml](../monitoring/prometheus.yml).

**Breaking Change:** Die beiden nativen Gateway-Konfigurationen verlangen jetzt
explizit `require_auth_for_metrics_endpoint: true`. Einen fuer den gewaehlten
LiteLLM-Pin gueltigen Token separat provisionieren; keine Schluessel in argv oder
Git. Nicht Auth abschalten, wenn ein noch nicht provisionierter Scrape fehlschlaegt.
Der bestehende ServiceMonitor verwendet derzeit den Gateway-Master-Key. Einen
dedizierten Metrics-Lesetoken mit dem konkret gepinnten LiteLLM separat pruefen;
Authentifizierung allein ersetzt noch keinen Least-Privilege-Nachweis.
Prometheus-Regeln allein versenden keine Nachrichten: Alertmanager/Notifier und
eine echte Testzustellung bleiben separate Abnahmen.

Tokenrate und Inferenzlatenz ueber die schon vorhandenen LiteLLM-Callbacks und
Dashboards nachweisen. Der Inventarexporter liefert bewusst weder Tokenrate noch
GPU-Temperatur. Direkte Ollama-Anfragen umgehen Gateway-Metriken.

## Patch 2: freigegebener stdio-MCP-Einstieg

Der [Launcher](../scripts/agents/mcp_launcher.py) verwendet nur den vorhandenen
Audio-Planer und den aktuell ausgefuehrten Python-Interpreter. Keine dynamischen
Executables, Shell, npx/pip-Nachinstallation, fremden Pfade oder Remote-URLs.
API-Key-/Proxy-/Python-Umgebungsvariablen werden beim Start nicht weitergereicht.

```bash
# Nur Plan; kein MCP-Prozess, Download oder Dateischreiben.
python3 -I -B scripts/agents/mcp_launcher.py plan

# Separat freigeben: Standard-mcpServers-JSON mit passenden absoluten Pfaden ausgeben.
python3 -I -B scripts/agents/mcp_launcher.py config --approve audio_plan
```

Den ausgegebenen Abschnitt bewusst in die Konfiguration des eigenen MCP-Clients
uebernehmen. Ein konfigurierter Client kann den Prozess automatisch starten;
deshalb verlangt auch die Config-Ausgabe eine Freigabe. Der Startweg lautet:

```bash
python3 -I -B scripts/agents/mcp_launcher.py run --approve audio_plan
```

Nur fuer einen MCP-Client bestimmt, kein interaktiver Chat und kein Hintergrund-
oder Netzwerkdienst. stdout ist ausschliesslich JSON-RPC. Modellinferenz durch
Ollama allein ist noch kein MCP-Client. Audio-Rendering und Videobearbeitung
werden nicht faelschlich als implementierte Tools registriert.

Websuche: vorhandene SearXNG-/Crawler-Pfade zuerst mit URL-Allowlist, SSRF-Schutz,
Robots-/Rate-Limits und Datenvertrag abnehmen. Filesystem-MCP nur innerhalb einer
nachgewiesenen OS-Sandbox und eines einzelnen freigegebenen Worktrees anbinden.
Remote-MCP benoetigt separat TLS-/Origin-/OAuth-Pruefung, Host-Allowlist und
Budgetfreigabe. Diese drei Adapter sind hier **nicht freigegeben**; der Launcher
weist entsprechende Argumente technisch ab. Er ist keine allgemeine OS-Sandbox.

## Patch 3: begrenzter Inventory-GET-Retry

Der bestehende Broker wiederholt nur `GET /api/tags` zum bereits validierten
Loopback-Ollama. Maximal drei Versuche; Backoff 0,25/0,5 Sekunden plus kleiner
Jitter. Retry nur fuer Transportfehler und HTTP 429/502/503/504. Verbindungen
werden vor dem Warten geschlossen. Payload-, Auth-, Redirect- und JSON-Fehler
bleiben Fehler, kein Cloud-Fallback und kein Modell-Download.

`Retry-After` in ganzen Sekunden wird eingehalten. Ist die Wartezeit groesser
als zwei Sekunden oder das verbleibende Budget, endet der Aufruf ohne fruehen
Retry. HTTP-Datumswerte oder ungueltige Header stoppen konservativ ebenfalls.
Neue Versuche werden nach Ablauf des 20s-/Session-Budgets nicht mehr begonnen.
Socket-Timeouts gelten pro blockierender Operation, nicht als harter Wanduhr-
Abbruch gegen einen trickelnden Server. Kein allgemeines HTTP-Middleware-Paket.

Inferenz-POSTs und Streaming bleiben einmalige Aufrufe: nach einem Verbindungs-
abbruch ist unbekannt, ob die Generierung bereits lief. Automatische Wiederholung
koennte GPU-Arbeit, Kosten oder Toolaktionen duplizieren. Fuer echte Failover-
Routen erst Modell-/Digest-Aequivalenz, Datenfreigabe, Queue und Abbruchvertrag
abnehmen; `num_retries: 0` im Gateway bleibt unveraendert.

## Sinnvolle Ergaenzungen, keine automatische Installation

| Komponente | Einordnung | Nutzen und Abnahme |
|---|---|---|
| NVIDIA DCGM Exporter | Dedizierter Installer fehlt im geprueften Toolkatalog; Metrikreferenzen existieren | Temperatur/Framebuffer/Utilization des Home-Workers; GPU-/Treiberunterstuetzung und Hostrechte zuerst pruefen, ausdruecklich opt-in. |
| gVisor/runsc | Kein eigener Installer im geprueften Toolkatalog | Staerkere Isolation fuer CPU-/Code-Worker unter kompatibler CRI; kein pauschaler CUDA-/GPU-Sandbox-Ersatz und keine Docker-Installation. |
| OpenTelemetry Collector | Bereits vorhanden, nicht neu hinzufuegen | Zuerst redigierte Spans aus Gateway/Agenten anschliessen, keine Prompts/Keys als Attribute; begrenzte Queue, Sampling und Retention. |
| vLLM | Bereits geplant | Nur auf ausreichend grosser Home-GPU benchmarken; kein kostenloser Gewinn auf ARM-/CPU-VPS. Vorher Modell-/VRAM-Budget und Wartezeiten messen. |

Keine dieser Empfehlungen ist ein Installationsauftrag. Ein Source-Pin, klare
Lizenz, Ressourcenbedarf und gesonderte Tests sind vor Aufnahme/Start noetig.
Nicht gleichzeitig CNI, Storage, Gateway und Agentenorchestrator austauschen.

## Abnahme, Rollback und Restarbeiten

Offline-Suite:

```bash
python3 -B -m unittest discover -s tests -p test_infrastructure_increment.py -v
python3 -B -m unittest discover -s tests -p test_coding_workbench.py -v
python3 -B -m unittest discover -s tests -p test_platform_gap_additions.py -v
```

Die bestehende Offline-Regression-CI entdeckt das neue Testmodul automatisch.
Schema-/Render-/promtool-Pruefung, echte Scrapes, Benachrichtigung, MCP-Handshake
mit dem eigenen Client und echte Inferenz-/PVC-Restore-Abnahmen bleiben separat.
Fixtures sind kein Nachweis fuer Produktionsbetrieb.

Lokaler Teilsatz: 73 Tests bestanden, zwei Kustomize-Render-Fixtures mangels
vorhandenem Kustomize uebersprungen. Die 14 neuen Infrastrukturtests enthalten
auch einen kurzlebigen stdio-Handshake mit dem lokalen read-only Planer. Der
vollstaendige Workbench-Testlauf erreichte unter Windows das lokale Zeitlimit;
die neun betroffenen Broker-Tests wurden danach vollstaendig erfolgreich
ausgefuehrt. Registry: null Fehler, 566 bestehende Metadatenhinweise. YAML-/Helm-
Render und promtool sind hier nicht abgenommen; PyYAML war lokal nicht vorhanden.
Keine Gesamt-CI-Abnahme und keine Veroeffentlichung durch diesen Review.

Rollback: drei unabhaengige Diffs. Inventar-Alert kann ohne Nutzdatenmigration
entfernt werden; Metrics-Auth nicht ersatzlos auf oeffentlichen Endpunkten
zuruecknehmen. MCP-Clienteintrag entfernen und den vom Client gestarteten Prozess
beenden. Broker-GET kann auf einmaligen Versuch zurueckgesetzt werden. Kein
Secret-/PVC-/User-Workspace-Loeschen, kein automatisches Deployment oder Merge.

P0: Legacy-Secrets/argv bereinigen, bevor dieser Altstack jemals neu gestartet
wird. P1: CNI-/VPN-Negativtests, externe Alarmzustellung, echte Restore-/GPU-
Abnahme. P2: genau einen lokalen Jobpfad mit Queue-Backpressure stabilisieren.
P3: erst danach verteilten Speicher oder alternative Inferenzserver evaluieren.

## Gepruefte primaere Quellen

- [Prometheus Alertregeln](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/).
- [MCP stdio / Streamable HTTP](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports).
- [NVIDIA DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter).
- [gVisor](https://github.com/google/gvisor).

Fruehere Reviews: [Architektur](ARCHITECTURE_REVIEW_2026-10-25.md),
[Plattformluecken](PLATFORM_GAP_IMPLEMENTATION_2026-10-27.md),
[Secure Core](SECURE_CORE_REFACTOR.md), [GitOps](GITOPS_SMALL_VPS.md).
