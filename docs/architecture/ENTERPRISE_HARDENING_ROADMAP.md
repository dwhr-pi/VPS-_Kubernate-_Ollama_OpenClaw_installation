# Arbeitsplan: Hybrid-KI schrittweise betriebssicher machen

Stand: 2026-11-12. Dieser Plan fuehrt den Architekturreview in einzeln abnehmbare Arbeitspakete ueber.
Er ist keine Produktionsfreigabe und behauptet keine bereits getestete Cluster- oder Modellinstallation.

## Hier weiterarbeiten

**Naechstes Arbeitspaket: E01, Metrics-Zugang vom LiteLLM-Master-Key trennen.**
Zuerst die API-/Authentifizierungsmoeglichkeiten des gepinnten LiteLLM-Quellstands pruefen.
Nicht einfach den Secret-Namen tauschen: Ohne passenden Empfaenger wuerde der Scrape nur mit 401 scheitern.
Danach E02 und E03 abschliessen, bevor produktive Agenten fremden Code ausfuehren oder sensible Daten verarbeiten.
Neue Infrastruktur nicht auf einmal aktivieren; pro Arbeitspaket einen kleinen, separat pruefbaren PR erstellen.

Verbindlich bleiben [AGENTS.md](../../AGENTS.md) und die
[Installationsrichtlinie](../INSTALLATION_POLICY.md): gepinnte Git-Quellen, native Builds,
kein Docker-/Compose-Installationsweg oder -Fallback, keine automatischen Dienst-/Modell-/Clusterstarts.
Secrets bleiben ausserhalb des Repos; `~/.openclaw_ultimate_user_data` bleibt erhalten.

## Ausgangsstand und Nachweisgrenzen

Der Review verglich GitHub-main `fc8100db9a5ba2f52f9c0b44cbf64e4d14c51daa` mit dem lokalen
Commit `9df791d029be8049b972f01cd20cd2e56ef90c30`. Die unten genannten LiteLLM-, Qdrant-,
ServiceMonitor- und Broker-Dateien waren in beiden Staenden inhaltlich identisch.
Die zusaetzlichen lokalen Monitoring-Aenderungen sind davon getrennt; ein Commit oder Merge ist kein Runtime-Test.
Vor Beginn jedes Arbeitspakets HEAD, Arbeitsstatus und spaetere Main-Aenderungen erneut pruefen.

| Bereich | Belegter Bestand | Offene Betriebsgrenze |
| --- | --- | --- |
| Gateway | [LiteLLM](../../k8s/base/litellm.yml), Auth, Limits, Probes, Non-root | Eine Replik, Recreate, kein belegter gemeinsamer HA-Zustand |
| Netzwerk | [Default-Deny und Freigaben](../../k8s/base/network-policy.yml) | CNI-Wirksamkeit, VPN, Ingress-Labels und neue Datenpfade am Ziel pruefen |
| Modelle | [Ollama-StatefulSet/PVC](../../k8s/base/ollama.yml) | Modellbestand, Lastgrenzen und GPU-Scheduling nicht durch Probes bewiesen |
| Vektorspeicher | [Qdrant-PVC und API-Key](../../k8s/gitops/memory/qdrant.yaml) | local-path, eine Replik, kein HA-/Restore-Nachweis |
| Monitoring | [Tool-Katalog, Regeln und Dashboard](../monitoring/ALL_TOOLS_OBSERVABILITY.md) | Katalogabdeckung ist keine Laufzeitabdeckung; promtool/Grafana-Abnahme offen |
| Tracing | Langfuse-Registry und natives Rezept vorhanden | Keine belegte produktive Agenten-Trace-Kette |
| vLLM | Registry-Eintrag geplant | Kein abgenommener nativer Build-/GPU-/Modellvertrag |
| Sandbox | [Historischer Modul-Leitfaden](../CODE_SANDBOX_USAGE_GUIDE.md) | Kein Nachweis fuer gVisor-/MicroVM-Isolation dieses Moduls |

Ressourcenlimits, PVCs, API-Authentifizierung und NetworkPolicies sind also nicht pauschal fehlend.
Sie muessen erhalten und durch gezielte Last-, Negativ-, Restore- und Isolationstests ergaenzt werden.
Der fruehere Windows-MCP-Fixture-Timeout ist separat zu untersuchen; diese Dokumentation behebt ihn nicht.

## Reihenfolge und Fortschritt

Ein Haken bedeutet bestandene Abnahme mit verlinktem Nachweis, nicht nur vorhandene Dateien.

| Prioritaet | ID | Arbeitspaket | Abhaengigkeit | Stand |
| --- | --- | --- | --- | --- |
| P1 | E01 | Metrics-Zugang mit minimalen Rechten | Gepinnter LiteLLM-Stand | Offen |
| P1 | E02 | Qdrant-/Agenten-Restore | Separater Testdatensatz und Sicherungsziel | Offen |
| P1 | E03 | MCP-/Code-Sandbox | Gepruefte Host-/Runtime-Voraussetzungen | Offen |
| P2 | E04 | Begrenztes echtes Streaming | Broker-Vertrag und Offline-Fixtures | Offen |
| P2 | E05 | Inferenz-SLOs und GPU-Telemetrie | E04, fuer vLLM dessen Build-Abnahme | Teilvorbereitung: Katalog/Dashboard |
| P2 | E06 | Redigiertes Agenten-Tracing | E01, Datenflussentscheidung | Langfuse-Rezept vorhanden |
| P3 | E07 | Mandantengetrennter Cache | Lastprofil, Daten-/Cache-Vertrag | Redis eingetragen, Integration offen |
| P3 | E08 | Gateway-/Storage-HA | E01, E02, gemeinsame Datenbasis | Offen |
| P3 | E09 | Lastabhaengige Worker-Skalierung | E05, E08, reale Zusatzkapazitaet | Offen; nicht aktivieren |

## P1: Sicherheit und Wiederherstellung

### E01: Metrics-Zugang trennen

Fundstelle: [LiteLLM-ServiceMonitor](../../k8s/monitoring/litellm-service-monitor.yml) verwendet
`litellm-runtime/master-key`. Prometheus braucht keine Gateway-Administrationsrechte.

- [ ] Am gepinnten Quellstand feststellen, welche eingeschraenkte Metrics-Authentifizierung unterstuetzt wird.
- [ ] Falls noetig einen separaten Metrics-Proxy planen: nur GET `/metrics`, keine API-/Admin-Weiterleitung.
- [ ] Eigenen Scrape-Token ausserhalb von Git erzeugen; Secret-/Mount-/RBAC-Vertrag separat dokumentieren.
- [ ] Den eventuell weiter benoetigten Upstream-Master-Key nur im Proxy halten, nicht an Prometheus geben.
- [ ] NetworkPolicies fuer Prometheus -> Proxy und Proxy -> Gateway begrenzen; bisherige Freigaben anpassen.
- [ ] Negativtests: ohne/falscher Token verweigert; Scrape-Token darf weder Inferenz noch Administration aufrufen.
- [ ] Positivtest: Prometheus scrapt; Logs/Traces/Fehler enthalten keine Tokens; Rotation ohne offenen Fallback pruefen.

**Fertig, wenn:** eingeschraenkter Zugriff samt Rotation und Negativtests am Ziel nachgewiesen ist.
Rueckfall: neue Scrape-Anbindung deaktivieren und ueberwachen, nicht Auth abschalten oder Key-Rechte ausweiten.
Bei Verdacht auf Offenlegung den alten Master-Key nach geprueftem Rotationsplan ersetzen.

### E02: Restore statt nur PVC

Fundstelle: [Qdrant](../../k8s/gitops/memory/qdrant.yaml) nutzt local-path/RWO und eine Replik.
Ein zweiter Pod oder ein lokaler Snapshot allein ueberlebt keinen Verlust des Speicher-Nodes.

- [ ] RPO und RTO fuer Agenten-Workspace, Konfigurationen und Vektordaten getrennt festlegen.
- [ ] Versionsgebundene Qdrant-Snapshots und konsistente Workspace-/Datenbank-Sicherungen definieren.
- [ ] Verschluesselte, getrennte Sicherung ausserhalb des Quell-Nodes mit minimalen Rechten vorsehen.
- [ ] Restore nur in einen neuen isolierten Test-Namespace bzw. ein neues Zielverzeichnis durchfuehren.
- [ ] Collections, Punktzahlen, Payloads, Embedding-Dimensionen und exemplarische Suchen vergleichen.
- [ ] Restore-Dauer, Verlustfenster und gepruefte Softwareversionen aufzeichnen.

**Fertig, wenn:** ein realer, reproduzierbarer Restore den vereinbarten RPO/RTO erreicht.
Produktiv-PVCs nicht loeschen, Datenbanken nicht zuruecksetzen und Nutzerdaten nicht ueberschreiben.
Velero-/CSI-Snapshot-Verfuegbarkeit pruefen; local-path hat nicht automatisch CSI-Snapshots oder Replikation.

### E03: Sandbox wirklich isolieren

- [ ] CPU-Tooljobs von GPU-Inferenz und vom privilegierten Control Plane/Gateway trennen.
- [ ] gVisor/runsc oder Kata bewerten; Firecracker benoetigt eine passende Kubernetes-/Runtime-Integration.
- [ ] Host-KVM, Architektur und Runtime-Kompatibilitaet pruefen; VPS kann Nested Virtualization ausschliessen.
- [ ] Runtime nativ aus geprueften Quellen einrichten; erst danach eine getestete RuntimeClass zuordnen.
- [ ] Jobs mit Non-root, Read-only-Root, Capability-Drop, Laufzeit-/PID-/CPU-/RAM-/Output-Limits vorsehen.
- [ ] Keine Host-Sockets, hostPath-Mounts, ServiceAccount-Tokens oder Secrets an untrusted Tooljobs geben.
- [ ] Default-Deny-Egress; erlaubte Broker-Zugaenge nur ueber begrenzte, authentifizierte Schnittstellen.
- [ ] Negative Tests fuer Hostdateien, Metadata-IP, Cluster-API, fremde Namespaces und externe URLs ausfuehren.
- [ ] Dateiuebergabe, Symlinks, Archive, Abbruch, Zombie-Prozesse und Logredaktion pruefen.

**Fertig, wenn:** Isolation mit dokumentierter Bedrohungsannahme und echten Negativtests belegt ist.
Ein gesetztes `runtimeClassName` ist kein Isolationsnachweis. Bei fehlender Runtime abbrechen,
nicht auf Host-Ausfuehrung oder eine weniger isolierte Runtime ausweichen.
GPU-Unterstuetzung von gVisor ist gesondert verfuegbar, aber kein Grund, beliebige MCP-Jobs an GPUs zu lassen.

## P2: Streaming, Messung und Agenten-Traces

### E04: Broker-Streaming begrenzt weiterreichen

Der [lokale Broker](../../scripts/agents/model_broker.py) puffert Antworten vollstaendig bis zur 8-MiB-Grenze.
Das ist eine bewusst begrenzte Sicherheitskomponente, kein HA-Gateway fuer alle Clients.

- [ ] Streaming- und Nicht-Streaming-Vertrag festlegen, ohne vorhandene Pfad-/Modell-/Budgetgrenzen zu entfernen.
- [ ] SSE-Stuecke zeitnah weiterreichen; Byte-Limit, Gesamtdauer, Idle-Timeout und Backpressure erhalten.
- [ ] Client-Abbruch muss Upstream-Verbindung und belegten Slot freigeben.
- [ ] Offline-Fixtures fuer fruehes erstes Token, langsame Clients, Oversize und Stream-Abbruch ergaenzen.
- [ ] Keine transparente Wiederholung nach bereits ausgegebenen Tokens oder moeglichen Tool-Seiteneffekten.

**Fertig, wenn:** Fixtures und bewusst freigegebener Streaming-Test TTFT und Abbruchverhalten nachweisen.
Rueckbau durch deaktivierten neuen Streaming-Pfad, nicht durch Entgrenzung des Brokers.

### E05: SLOs mit belegten Metriken

- [ ] SLOs fuer TTFT, Inter-Token-Latenz, Gesamtzeit, Queue-Wartezeit und Fehlerrate je Modellklasse festlegen.
- [ ] Ollama-Streaming am Gateway messen; Tokenzaehlung, Abschlussantwort und Fehlerabbruch getrennt behandeln.
- [ ] Fuer vLLM zuerst nativen Build, Lizenz, Modell-Digest, GPU-/Treibervertrag und Speicherbudget abnehmen.
- [ ] Metriknamen und Histogramm-Buckets gegen genau diese Version pruefen, nicht gegen bewegliches latest.
- [ ] DCGM-Framebuffer, GPU-Temperatur und frameworkinternen KV-/Allocator-Zustand getrennt darstellen.
- [ ] Keine VRAM-Fragmentierung aus einer einfachen Belegt/Frei-Quote ableiten.
- [ ] [Vorbereitetes Tool-Monitoring](../monitoring/ALL_TOOLS_OBSERVABILITY.md) mit promtool und Grafana abnehmen.
- [ ] Labels auf Modell-ID/-Revision und Standort begrenzen; keine Prompts, Nutzer-IDs oder Secrets als Labels.
- [ ] Lasttest nur mit freigegebenen synthetischen Daten, festen Abbruchgrenzen und ohne Modell-Pull.

**Fertig, wenn:** Dashboardwerte zu einem bekannten Testlauf passen und Alarme samt Datenverlustfall getestet sind.
Katalogeintraege und `up=1` sind weder TTFT- noch Inferenzqualitaetsnachweise.

Beispielausdruecke fuer eine vLLM-Version mit entsprechendem Metrikvertrag:

```promql
histogram_quantile(0.95, sum by (le, model_name) (rate(vllm:time_to_first_token_seconds_bucket[5m])))
sum by (model_name) (rate(vllm:generation_tokens[5m]))
sum by (model_name) (vllm:num_requests_waiting)
```

Counter-Namen koennen versionsabhaengig sein. Keine automatische Umbenennung oder Null-Auffuellung bei Datenverlust.

### E06: Genau ein Tracing-Backend zuerst

Langfuse hat bereits einen Registry-Eintrag und ein natives Rezept in
[docker_to_github.json](../../config/docker_to_github.json); es ist nicht pauschal ein fehlendes Tool.
Postgres, ClickHouse, Redis/Valkey und Objektspeicher sind getrennte Betriebsabhaengigkeiten.
Phoenix ist eine Alternative, keine automatisch gleichzeitig zu installierende Pflichtkomponente.

- [ ] Zwischen Langfuse und Phoenix anhand Ressourcen, Lizenz und benoetigtem Funktionsumfang entscheiden.
- [ ] Geprueften Source-Pin, native Buildschritte, SBOM und Upgrade-/Migrationspfad festlegen.
- [ ] OpenTelemetry-Spans fuer Agent, Modellaufruf und MCP-Tool mit gemeinsamer Trace-ID verbinden.
- [ ] Prompt-/Antwortaufzeichnung standardmaessig minimieren; redigierte Metadaten und Sampling bevorzugen.
- [ ] Aufbewahrung, Zugriff, Verschluesselung und Loeschverfahren definieren; keine Credentials in Spans.
- [ ] Verbindungsabbruch des Tracing-Backends darf Agenten nicht blockieren oder unbegrenzte Puffer erzeugen.

**Fertig, wenn:** eine synthetische mehrstufige Agentenaktion redigiert nachvollziehbar ist,
inklusive Fehlerpfad, Sampling, Retention und abgegrenzter Benutzerrechte.

## P3: Cache, HA und Skalierung

### E07: Cache nur mit Datenvertrag

- [ ] Redis/Valkey-Kompatibilitaet des gepinnten Gateways pruefen; TLS, ACL und Ressourcenlimits vorsehen.
- [ ] Zuerst exaktes Caching fuer freigegebene, nebenwirkungsfreie Anfragen evaluieren.
- [ ] Cache-Key um Mandant, Modell-Digest, Systemprompt, Generierungsparameter und RAG-/ACL-Version ergaenzen.
- [ ] TTL, Invalidierung, Datenloeschung und Verbot sensibler Cache-Inhalte testen.
- [ ] Toolaufrufe, personenbezogene Antworten und Rechts-/Finanzentscheidungen nicht pauschal semantisch cachen.
- [ ] Semantisches Caching erst nach Embedding-/Suchbackend-, Fehlertreffer- und Mandantentrennungs-Abnahme.

**Fertig, wenn:** Hit-Rate und vermiedene Inferenz messbar sind und Cross-Tenant-Negativtests bestanden sind.
Redis/Valkey allein ist keine fertige semantische Cache-Pipeline. Kein unverschluesselter Cloud-Fallback.

### E08: HA vor dem Hochskalieren

- [ ] Gemeinsame Gateway-Datenbank sowie Budget-/Rate-Limit-/Routingzustand einrichten und testen.
- [ ] Zwei Gateway-Replikate auf getrennte Fehlerdomaenen verteilen; RollingUpdate/PDB abgestimmt vorsehen.
- [ ] CNI-/NetworkPolicy-Zugaenge zu Datenbank, Cache, Metrics und Modellservern minimal erweitern.
- [ ] Lokale Fallback-Gruppen nach Modellfaehigkeit, Lizenz, Kontext und Datenfreigabe definieren.
- [ ] Globale Deadline, Retry-Budget und Circuit-Breaker-Verhalten mit dem gepinnten Gateway testen.
- [ ] Keine Proxy-/Client-Retry-Kaskaden und keine Wiederholung mutierender Agentenaktionen zulassen.
- [ ] Qdrant-HA oder replizierten Storage nur mit passender Node-Anzahl und getesteten Fehlerfaellen ergaenzen.

**Fertig, wenn:** Ausfall eines Gateways keine Budgetumgehung verursacht und definierte SLOs eingehalten werden.
Mehrere Pods auf einer einzigen GPU oder einem einzigen Datentraeger sind keine HA.

### E09: KEDA erst nach Kapazitaetsnachweis

- [ ] Zusaetzliche GPUs/Worker und Kosten-/RAM-/VRAM-/Quota-Budget nachweisen.
- [ ] Pro Replik Modellzugang, Modellbestand und Warmup separat ohne automatischen Download vorbereiten.
- [ ] Lastverteilung auf mehrere Modellserver testen; sticky/imbalance-Effekte der Queue-Metrik pruefen.
- [ ] KEDA-CRDs, Metrics-API, Auth und minimale Netzwerkfreigaben getrennt einrichten.
- [ ] Skalierungsobjekt zunaechst pausiert halten; Mindest-/Maximalreplikate und Stabilisierung festlegen.
- [ ] Kein Null-Fallback fuer verschwundene Metriken; Ausfall der Datenquelle als Fehler pruefen.
- [ ] Zweite Replik, Modell-Ladezeit, Downscale-Drain und nicht verfuegbare GPU in Staging testen.

**Fertig, wenn:** Skalierung unter Last den SLO verbessert, statt nur Pending-Pods oder Modell-Thrashing zu erzeugen.
KEDA schafft weder neue Hardware noch einen verteilten Modellcache und ist auf einem Einzel-GPU-Worker kein Muss.

## Inaktive Integrationsvorlage fuer E05/E09

Dies ist kein vollstaendiges vLLM-Deployment und kein Installationsbefehl.
Vorbedingungen: geprueftes Deployment `vllm`, Service mit Label `app: vllm` und Portname `http` in `llmops`,
Prometheus Operator/CRDs, KEDA/CRDs und passende NetworkPolicies.
Der Monitor braucht passende Prometheus-Monitor-Selektoren.
`/metrics` muss ausschliesslich privat erreichbar sein; Auth/TLS nach dem freigegebenen Scrape-Vertrag ergaenzen.
Die Prometheus-Adresse ist ein Beispiel und muss am Ziel verifiziert werden.
Der Scaler bleibt bis zur gesonderten Hardware-/Lastabnahme pausiert.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: vllm
  namespace: llmops
  labels: {release: llmops-monitoring}
spec:
  namespaceSelector: {matchNames: [llmops]}
  selector:
    matchLabels: {app: vllm}
  endpoints:
    - port: http
      path: /metrics
      interval: 30s
      scrapeTimeout: 5s
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: vllm-queue
  namespace: llmops
  annotations: {autoscaling.keda.sh/paused: "true"}
spec:
  scaleTargetRef: {name: vllm}
  minReplicaCount: 1
  maxReplicaCount: 2
  pollingInterval: 30
  cooldownPeriod: 300
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus-operated.monitoring.svc:9090
        query: sum(vllm:num_requests_waiting{namespace="llmops"})
        threshold: "4"
        ignoreNullValues: "false"
```

Dieser Scaler darf nicht auf Ollama zeigen und gleichzeitig vLLM-Queues auswerten.
Bei mehreren Modellgruppen die Query auf genau die Zielgruppe einschraenken.
Die Kubernetes-/KEDA-API-Abnahme und der Lasttest dieser Vorlage sind noch offen; nichts daraus wurde angewandt.

## Nachweise je Arbeitspaket

Den folgenden Block im jeweiligen PR bzw. in einem separaten redigierten Abnahmebericht ausfuellen:

```text
Arbeitspaket: E01 ... E09
Bearbeiter / Datum:
Gepruefter Setup-Commit und Source-/Modell-Pins:
Umgebung / isolierter Testdatensatz:
Freigabe fuer Build, Clusterzugriff, Inferenz oder Benachrichtigung:
Offline-Tests und Exitcodes:
Positiv-/Negativ-/Ausfalltest und gemessene Ergebnisse:
Rollback getestet:
Restliche Grenzen / Entscheidung:
```

Keine Secret-Werte, privaten Hostnamen, Prompts oder Nutzerdaten in oeffentliche PR-Berichte aufnehmen.
Nur nach abgeschlossenem Arbeitspaket dessen Checkliste abhaeken und die Fortschrittstabelle aktualisieren.
Die P1-Schritte zuerst abnehmen; P2/P3 bleiben bis zur Erfuellung ihrer Voraussetzungen offen.

## Primaerquellen

- [vLLM-Metrikvertrag](https://docs.vllm.ai/en/latest/usage/metrics/)
- [LiteLLM: Retries und Fallbacks](https://docs.litellm.ai/docs/router/learn/reliability)
- [LiteLLM: Caching](https://docs.litellm.ai/docs/proxy/caching)
- [KEDA: Prometheus-Scaler](https://keda.sh/docs/2.21/scalers/prometheus/)
- [KEDA: ScaledObject](https://keda.sh/docs/2.21/reference/scaledobject-spec/)
- [gVisor: GPU-Grenzen](https://gvisor.dev/docs/user_guide/gpu/)
- [Langfuse Self-Hosting](https://langfuse.com/self-hosting)
- [Phoenix Self-Hosting](https://arize.com/docs/phoenix/self-hosting)

Die verlinkten beweglichen Upstream-Dokumentationen sind Orientierung, kein Ersatz fuer den im Arbeitspaket
festgelegten Pin und dessen eigene Dokumentation. Keine ungeprueften Quellskripte ausfuehren.
