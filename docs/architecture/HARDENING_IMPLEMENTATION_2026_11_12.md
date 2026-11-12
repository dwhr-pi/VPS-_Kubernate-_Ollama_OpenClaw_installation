# Haertung: Metrics-Grenze, Preflight und suspendierte Sandbox

Stand: 12.11.2026. Implementierungsstand, **keine Produktionsfreigabe**.
Dieser Schritt setzt E01 strukturell um und bereitet E03 vor. E02 und
E04-E09 bleiben offen; es wurden keine Dienste, Cluster oder Modelle gestartet.

## Ausgangsstand und Quellenpruefung

Lokaler HEAD vor den Aenderungen: `3b4c62e81f8afe75a13f0f97170b5242c9e095b6`.
GitHub-main wurde rein lesend mit `git ls-remote` als
`ea1714bf590d4d181b132d430a3eba5dca1307e8` festgestellt; das Objekt war lokal
vorhanden. Der Vergleich zeigte 14 geaenderte Dateien, vor allem den zuvor
ergaenzten Projektbrief. Kein Pull, Checkout, Merge, Commit oder Push.

Das native LiteLLM-Rezept pinnt `f2118fc7670ba3fa736d9b8f4deef9077a45a720`.
Authentifizierung und Typ-/Serverdateien wurden an diesem Commit gelesen,
nicht ausgefuehrt. Der Master-Key erhaelt dort Adminrechte; eine ausschliesslich
auf Metrics begrenzte Tokenfaehigkeit ist nicht nachgewiesen.
[Original-URLs, Hashes und Nachweisgrenzen](../quality/LITELLM_METRICS_SOURCE_2026-11-12.json).
Neuere Online-Dokumentation ersetzt keine Pruefung des gepinnten Quellstands.

## E01: Getrennter Scrape-Zugang

Das [opt-in Overlay](../../k8s/overlays/metrics-isolation/kustomization.yaml)
verwendet die bestehende Kustomize-Basis und fuegt eine kleine Python-Bridge
im LiteLLM-Pod hinzu. Es entsteht keine zweite Gateway-Workload-Definition.
Die Bridge verwendet dieselbe separat gepruefte native Python-Runtime wie
LiteLLM, fuehrt aber nur ihren stdlib-Code aus. Keine zusaetzlichen Pakete,
kein Docker-Fallback und kein Paketdownload beim Start.

| Verbindung | Zugang | Erlaubt |
| --- | --- | --- |
| Prometheus -> `litellm-metrics:9092` | Eigenes Secret `litellm-metrics-scrape/token` | Nur GET `/metrics` |
| Bridge -> `127.0.0.1:4000` | `litellm-runtime/master-key`, nur in der Bridge | Festes GET `/metrics` |
| Traefik -> LiteLLM | Vorhandene API-Authentifizierung | Bestehender Gateway-Vertrag |

Die Bridge akzeptiert keine Admin-/Inferenzpfade, Queryparameter, Request-Bodies,
Redirects, Ziel-URLs oder fremden Header zur Weiterleitung. Upstream-Anfragen
haben ein Gesamtzeitbudget von drei Sekunden, maximal 4 MiB Antwort und keine
Retries. Eingehende Verbindungen sind seriell, zeitbegrenzt und mit kleiner
Warteschlange ausgelegt: kein allgemeiner HA-Proxy. Antworten mit einem der
beiden Tokens werden verworfen; Fehler und Logs geben keine Tokens/Inhalte aus.
Das entfernt nicht automatisch personenbezogene Metriklabels: deren Auswahl
und Aufbewahrung vor Aktivierung gesondert pruefen.

Prometheus bekommt **nicht** den Master-Key. Im Operator-Namespace des
ServiceMonitor (`llmops`) liegt nur der zusaetzliche Scrape-Token fuer dessen
Referenz. Vorhandene Operator-/Prometheus-RBAC-Berechtigungen separat pruefen:
die Aenderung entfernt keine bereits anderweitig vergebenen Secret-Leserechte.
Ein kompromittierter Bridge-Prozess besitzt weiterhin den Upstream-Key; er
ist eine vertrauenswuerdige Sicherheitskomponente, keine Sandbox fuer fremden Code.

### Bewusste Vorbereitung und Aktivierung

1. Native LiteLLM-Runtime mit Python und reproduzierbarem Digest bereitstellen.
2. Zwei unterschiedliche, unabhaengige Credentials ausserhalb von Git verwalten; keine Werte in YAML eintragen.
3. Den neuen Scrape-Token als Secret `litellm-metrics-scrape`, Schluessel `token`, bereitstellen.
4. CNI, Namespace-/Pod-Labels, Operator-RBAC und alle additiven NetworkPolicies pruefen.
5. Das Overlay lokal rendern und pruefen; Image-Platzhalter im eigenen geprueften Overlay ersetzen.
6. Erst nach ausdruecklicher Ziel-/Wartungsfreigabe anwenden; danach den angepassten ServiceMonitor aktivieren.

Schreibfreie Vorpruefung mit bereits vorhandenem geprueftem Kustomize:

```bash
kustomize build k8s/overlays/metrics-isolation
```

Das Overlay ist ein eigenstaendiger Basis-Ableger. Es nicht gemeinsam mit
`gpu`/`production` als zwei vollstaendige Basen einbinden. Fuer ein konkretes
Umgebungs-Overlay genau eine Basis verwenden und dessen GPU-/Ingress-Patches
gezielt uebernehmen; Ergebnis auf doppelte Ressourcen und Policy-Freigaben pruefen.
Den Image-Namen `registry.example.invalid/litellm` auf denselben geprueften
Digest fuer Gateway und Bridge setzen; keinen Platzhalter aktivieren.
Zusatzpfade fuer kube-system-Traefik oder WebUI bleiben gesondert zu konfigurieren.

Die NetworkPolicy fuer Gateway-Port 4000 wird im Overlay ersetzt: Prometheus
ist dort nicht mehr freigegeben. Fuer Port 9092 gilt nur die definierte
Prometheus-Namespace-/Pod-Kombination. Der ServiceMonitor nutzt jetzt den
Service `litellm-metrics`; Ausfall-/Missing-Alarme wurden entsprechend angepasst.
Ohne dieses Overlay gibt es keinen neuen Metrics-Port. Ein alter Scrape auf
Port 4000 darf nicht als stiller Master-Key-Fallback bestehen bleiben.

### Rotation, Abnahme und Rueckbau

Die Bridge liest Kubernetes-Projektionen bei jeder Anfrage neu; keine
`subPath`-Mounts. Bei Scrape-Tokenrotation koennen unterschiedliche Updatezeiten
kurzzeitig 401 verursachen. Das ist gewollt fail-closed, kein Grund fuer einen
zweiten dauerhaft gueltigen Token. Master-Key-Rotation mit dem Gateway-Rollout
koordinieren: dessen vorhandene Environment-Injection wird nicht live erneuert.

Echte Zielabnahme: korrekter Token liefert Metrics; falscher/fehlender Token
scheitert; Scrape-Token kann weder `/v1/chat/completions` noch `/key/generate`
aufrufen; direkter Port 4000 ist fuer Prometheus gesperrt; Rotation und
Ausfallalarme funktionieren. CNI-/RBAC-/Operator-Tests wurden lokal nicht ausgefuehrt.
`/healthz` belegt nur den Bridge-Prozess, keine funktionierende Upstream-Abfrage.

Rueckbau: Metrics-Scrape bewusst deaktivieren, Bridge-Overlay entfernen und
Alarmerwartung dokumentiert anpassen. Nicht den Master-Key erneut an Prometheus
geben, Auth deaktivieren oder Benutzerdaten loeschen.

### Nativer Betrieb ohne Kubernetes

Die [systemd-Vorlage](../../systemd/litellm-metrics-proxy.service) bindet
standardmaessig nur Loopback. Dienstbenutzer, geprueften Checkout unter
`/opt/openclaw-reviewed`, systemd-Unterstuetzung und private Credential-Dateien
separat vorbereiten. Nichts wurde installiert oder gestartet.
`LoadCredential` wird beim Dienststart uebernommen; Rotation dieser nativen
Unit braucht deshalb einen bewusst freigegebenen Neustart. Direkte, sichere
Dateipfade werden dagegen je Scrape gelesen. Native Prometheus-Ziele bleiben
leer, bis `127.0.0.1:9092` und ein eigener Scrape-Token freigegeben sind.
`/run/secrets/litellm-metrics-token` darf nicht den Gateway-Master-Key enthalten.

## Preflight ohne implizite Host-Inventur

`scripts/preflight.sh` delegiert jetzt an den vorhandenen Offline-Doctor.
Ohne Runtime-Freigabe: keine Host-/GPU-Abfrage, kein Docker-Erfordernis und
Exit 3 fuer unvollstaendige Laufzeitabnahme. Pin-Metadaten werden lokal geprueft.

```bash
bash scripts/preflight.sh --json
```

Nur nach bewusst erteilter lokaler Diagnosefreigabe:

```bash
bash scripts/preflight.sh --runtime --require gpu \
  --min-free-gib 20 --min-free-vram-mib 4096 --json
```

Freier VRAM wird pro GPU bewertet, nicht ueber mehrere GPUs addiert. Die
Momentaufnahme reserviert keinen Speicher und prueft weder CUDA-Toolkit noch
Device Plugin oder Modellpassung. Das Skript wendet niemals Manifeste an.
Treiber-/Runtime-Versionsmatrix, Lasttest und konkrete Hardwarebudgets bleiben offen.

## E03: Suspendierte Sandbox-Vorlage

[Tool-Sandbox](../../k8s/optional/tool-sandbox/kustomization.yaml) bereitet einen
getrennten Namespace mit Restricted Pod Security, Default-Deny, Quota und
tokenlosem ServiceAccount vor. Der Beispieljob ist `suspend: true`, ohne
Host-Mounts/Secrets und mit Non-root, Read-only-Root, Capability-Drop,
CPU/RAM/Scratch-Grenzen, Laufzeitlimit und ohne automatische Wiederholungen.
Die Job-TTL entfernt ausschliesslich den beendeten Beispieljob und seine Pods
nach einer Stunde. Bei spaeteren echten Tests Logs/Nachweise vorher getrennt
sichern; der suspendierte Job und Benutzerdateien werden dadurch nicht geloescht.

`runtimeClassName: runsc` behauptet keine vorhandene Runtime. gVisor muss
vorher nativ eingerichtet und am Ziel getestet sein; fehlende Runtime darf
keinen Host-Fallback ausloesen. PID-Grenzen, harte Output-Limits, Broker- und
Artefaktuebergabe sowie echte negative Isolationstests fehlen noch. Die
Vorlage ist kein automatisch angeschlossener OpenClaw-/MCP-Executor.

## Weitere Pakete und Tests

E02 bleibt ein echter Offsite-/Restore-Test mit neuem Ziel: Qdrant-Collections,
Punktzahlen, Payloads, Embedding-Dimensionen und Referenzsuchen sowie Workspace-
und Datenbankkonsistenz vergleichen. Der vorhandene pausierte Velero-Zeitplan
ist keine Sicherung und kein Ersatz fuer anwendungskonsistente Snapshots.
E04-E09 bleiben im [Arbeitsplan](ENTERPRISE_HARDENING_ROADMAP.md) priorisiert.
Keine neuen Tunnel, Operatoren, Cloud-Fallbacks oder konkurrierenden Helm-Charts.

```bash
python3 -B -m unittest discover -s tests -p test_metrics_isolation.py -v
python3 -B -m unittest discover -s tests -p test_hardening_preflight.py -v
python3 -B -m unittest discover -s tests -p test_platform_health.py -v
```

CI ergaenzt synthetische Linux-/macOS-/Windows-Fixtures sowie Render-/Lint-
Pruefungen fuer die zwei neuen Kubernetes-Pfade. Lokal getestete Fixtures sind
keine echte Token-, Cluster-, Restore-, Sandbox- oder Inferenz-Abnahme.
