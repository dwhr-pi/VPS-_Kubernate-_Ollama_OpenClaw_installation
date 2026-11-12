# Modell-Routing, GGUF-Export und Monitoring

Stand: 2026-11-11. Sichere Einordnung der gelieferten Orchestrierungs-,
Konvertierungs-, Benchmark-, Helm-, Alerting- und Dashboard-Vorlagen.
Keine Installation, Modellregistrierung, Inferenz oder Konfigurationsmigration
durch diese Dokumentation. GitHub-native bleibt der Installationsweg; kein Docker.

## Bestand statt vermeintlicher Defaults

| Familie | Geplanter Einsatz | Tatsaechlicher Nachweis und Lizenzgrenze |
| --- | --- | --- |
| Llama | Allgemeine Koordination | Nicht pauschal als installiertes Default ausweisen; genaue Variante und Meta-Modellbedingungen pruefen |
| Qwen-Coder | Code und Kubernetes | [Vorhandener Quellen-Eintrag](tools/qwen-coder.md), nicht automatisch heruntergeladene Gewichte |
| QwQ / DeepSeek-R1-Distill | Reasoning als Entscheidungshilfe | [Domain-Katalog](AUDIO_RECOGNITION_AND_DOMAIN_MODELS.md); kein zertifizierter Rechts-/Finanzexperte |
| Codestral / DeepSeek-Coder | Optionale Coding-Kandidaten | Genauen Checkpoint, dessen Nutzungsbedingungen und Runtime separat pruefen; nicht pauschal MIT oder kommerziell freigegeben |
| Faster-Whisper | Audio zu Text vor LLM-Routing | STT-Stufe, kein Text-LLM und kein automatisch gestarteter Dienst |

Ein Repo-Eintrag beweist weder installierte Modelle noch einen laufenden Dienst.
Die Tabelle im gelieferten Anhang darf deshalb nicht unveraendert als Ist-Zustand
uebernommen werden. Trainingsdatenrechte und komplette Trainingspipeline sind
separat von Code- und Gewichtslizenz zu beurteilen. Keine pauschale GPU-Mindestzusage
fuer QLoRA; Architektur, Kontext, Batch, Optimizer und Sequenzlaenge messen.

## Offline-Routingplan

[Planner](../scripts/models/openclaw_pipeline.py),
[inaktive Beispielkonfiguration](../config/llm_router.example.json).
Dies ist ein pruefbarer Vorschlag, kein aktiver OpenClaw-Router. Kein Netzwerk,
API-Key, Subprozess, Modell-Pull oder Schreiben in aktive Konfigurationen.
Alle Kandidaten starten mit license_reviewed=false und runtime_reviewed=false.

```bash
python3 -B scripts/models/openclaw_pipeline.py route-plan \
  --config config/llm_router.example.json \
  --installed examples/models/installed-models.empty.json \
  --task finance --free-vram-mib 0 --context 4096
```

Dieses Beispiel muss mit Exit 3 blockieren. Exit 0 ist nur ein Plan, kein
Runtime-Erfolg. Nach separater Pruefung eigene lokale Konfiguration und eine
JSON-Liste exakt installierter Modellnamen verwenden; niemals vorhandene
Nutzerdaten ueberschreiben. Reihenfolge legt Prioritaet/Fallback fest, nur
innerhalb derselben Aufgabenklasse und mit beiden Freigaben. Keine automatische
Nachquantisierung, Gewichtsinstallation, Modell-Entladung oder Cloud-Ausweichung.
Audio liefert Exit 3 und verlangt eine explizit freigegebene Transkriptionsstufe.

GET /api/ps liefert geladene Modelle und size_vram, aber keinen freien Gesamt-VRAM.
Nicht geladene, bereits installierte Modelle fehlen dort. Fuer Live-Anbindung
installierte Modelle separat erfassen und Kapazitaet ueber DCGM/NVML mit korrekter
GPU-Zuordnung messen. Momentaufnahme, parallele Reservierungen, KV-Cache und
Sicherheitsreserve sind keine atomare Admission Control. Der Planner vertraut
den explizit gelieferten Kapazitaets-/Profilwerten, behauptet keine Live-Messung.

Quantisierung und Kontext muessen mit dem tatsaechlichen Artefakt uebereinstimmen;
Tags allein belegen diese Werte nicht. Ein kleineres Fallback darf nur bereits
installiert und passend freigegeben sein. inference_time_seconds bleibt null,
weil keine Inferenz ausgefuehrt wurde. Modellgenerierte Reasoning-Texte sind
kein Korrektheitsbeweis oder verpflichtende interne Gedankenkette.

## Export und Ollama getrennt freigeben

```bash
python3 -B scripts/models/openclaw_pipeline.py export-plan \
  --name custom-legal-finance:review \
  --source /lokal/geprueft/merged_model \
  --llama-cpp /lokal/geprueft/llama.cpp \
  --destination /lokal/neuer-isolierter-export \
  --quantization Q4_K_M
```

Es werden nur Argumentlisten und ein Modelfile-Vorschlag ausgegeben, keine
Verzeichnisse oder Artefakte erzeugt. Kein shell=True und keine stillschweigende
Konfigurationsaenderung. Bereits gepinnten nativen llama.cpp-Build verwenden;
Architektur, Tokenizer, Converter-Flags und llama-quantize --help am konkreten
Pin pruefen. Nicht jede HF-Architektur ist konvertierbar.

Der Plan konvertiert zuerst nach F16 und quantisiert separat mit llama-quantize
nach Q4_K_M oder Q8_0. Das ist kein universeller Beweis, dass jeder Converter
beliebige Quantisierungen direkt als --outtype versteht. Modellarchitektur und
Quantisierungsqualitaet zuerst mit Holdout und Paritaetstests pruefen.
F16-Zwischenstand, quantisiertes Artefakt, temporaere Dateien und Ollama-Kopie
benoetigen gemeinsam Platz. Unmerged-LoRA, Basismodell-/Adapterrechte und
Merge-Herkunft sind vorab zu klaeren.

Nach separater menschlicher Freigabe in einem neuen Exportverzeichnis die
geprueften Argumentlisten ausfuehren, Ausgaben pruefen und SHA256 dokumentieren.
Modelfile verwendet PARAMETER, nicht PARAM. Ollama-Registrierung ist eine
eigene schreibende Aktion und startet keinen automatisch erlaubten Benchmark.
Keine Datei config/openclaw-config.yaml mit erfundenem agents-Array ueberschreiben.
Der Planner nennt nur einen Modellreferenz-Vorschlag; aktive OpenClaw-JSON5-
Konfiguration sichern, mit installierter Version validieren und separat bearbeiten.

## Benchmark-Nachweis

Ein HTTP-200 allein validiert kein Modell. Erst nach gesonderter Inferenzfreigabe:
JSON-Schema, kein error-Feld, done=true, nichtleere Antwort, endliche positive
eval_duration und nachvollziehbare eval_count pruefen. Tokens/s sind
eval_count / (eval_duration / 1e9), nicht fehlende Werte durch 0/1 ersetzen.
Wandzeit mit monotonic messen, Warm-/Kaltlauf trennen und bekannte Testaufgaben
mit erwarteten Ergebnissen nutzen. Keine vertraulichen Vertragsanfragen als
Smoke-Test und keine Modellantworten standardmaessig protokollieren.
Der neue Planner fuehrt diesen Benchmark absichtlich noch nicht aus.

## Kubernetes und Metriken

Die vorhandene [Ollama-Basis](../k8s/base/ollama.yml) ist der Single Source of
Truth: StatefulSet, retained PVC, /data/models, Non-root, Read-only RootFS,
Ressourcen und Startup-/Readiness-/Liveness-Probes. Der
[GPU-Patch](../k8s/overlays/gpu/k8s-ollama-deployment.yaml) ergaenzt GPU-Node,
RuntimeClass und nvidia.com/gpu. Nicht parallel ein zweites Deployment mit
latest, fehlendem PVC-Manifest und Root-Pfad aus der Vorlage anwenden.
K3s-CRI ist keine Docker-Installationsfreigabe. Keine chart-unabhaengig geratenen
Helm-Values als offiziell oder kompatibel ausweisen; erst Chart-Version pinnen.

Ollamas / und /api/tags sind keine Prometheus-Metriken. Der vorhandene
[read-only Exporter](../scripts/monitoring/ollama_readonly_exporter.py) liest
GET /api/ps. [ServiceMonitor und Regeln](../k8s/monitoring/runtime-observability.yml)
sind opt-in, benoetigen Operator-CRDs und passende Selektoren/Namespaces.
Der [LiteLLM-Monitor](../k8s/monitoring/litellm-service-monitor.yml) scrapt das
authentifizierte Gateway, nicht Ollama. Latenz-/Token-Metriknamen anhand des
tatsaechlichen Gateways pruefen; der Inventar-Exporter misst keine Inferenz.

[Vorhandenes Dashboard](../monitoring/grafana/dashboards/llmops.json) zeigt
Gateway-Latenz und Host/GPU. Die neue
[Inventaransicht](../monitoring/grafana/dashboards/ollama-inventory.json) verwendet
nur implementierte ollama_monitor-Metriken und optional DCGM. In Grafana ueber
Dashboards, New, Import laden; Prometheus-Datenquelle mit UID prometheus oder
angepasster UID verwenden. Kein Dashboard-Import oder Browserstart automatisch.
Fehlende Metriken als fehlend behandeln, nicht mit Null als gesund darstellen.
GPU-Metriken separat vom CPU-RAM zeigen; DCGM-FB_USED/(FB_USED+FB_FREE)
statt unbelegtem FB_TOTAL verwenden. Nur die passenden lokalen GPUs selektieren.

## Alerting und Discord

[Opt-in Performance-Regeln](../examples/monitoring/ollama-performance-rules.yaml)
trennen Gateway-p95 >15 Sekunden, Ollama-Container-RAM >90 Prozent des
nichtnull Limits und GPU-Framebuffer >90 Prozent. Vor einem Apply tatsaechliche
Metriknamen/Labels, Operator-Regelselektoren und PromQL mit promtool pruefen.
DCGM nur fuer bewusst ausgewaehlte lokale Worker scrapen; GPU-Auslastung ist
nicht exklusiv Ollama zuzurechnen. Ohne Traffic oder Metrikserie ist ein
Latenzquantil nicht aussagekraeftig. Keine echte Alarmierungsabnahme erfolgt.

[Opt-in Discord-Receiver](../examples/monitoring/discord-alertmanager-config.yaml)
verwendet discordConfigs und apiURL als SecretKeySelector. CRD-/Alertmanager-
Version, Config- und Namespace-Selektoren vorher pruefen. Secret
llmops-discord-webhook mit Key url liegt nur privat im selben Namespace llmops;
kein Klartext-Secret-Manifest im Git. Native Discord-URL ohne /slack verwenden.
Ein generischer Alertmanager-Webhook produziert kein Slack-JSON.

Der Beispielreceiver sendet nur critical, alle anderen verfallen im discard-
Receiver. Bei standardmaessigem Namespace-Matching muessen Alerts namespace=llmops
tragen; globale DCGM-Alarme werden nicht automatisch erfasst. Keine pauschale
clusterweite Freigabe als Abkuerzung setzen. Nachrichten sind konstant und
enthalten keine Logzeilen/Modellantworten. Keine Benachrichtigung getestet.
[Begrenzter Log-Monitor](OLLAMA_LOG_MONITOR.md) ist eine getrennte opt-in
Alternative, kein zweiter automatisch gestarteter Alerting-Dienst.

## Weiterfuehrung und Quellen

[Training/Evaluation](models/TRAINING_AND_EVALUATION.md),
[Open Weights/RAG/Herkunft](models/WEIGHTS_RAG_AND_PROVENANCE.md),
[Outlines und Reimpruefung](CREATIVE_LYRICS.md).
Beide identischen Pipeline-Anhaenge sind als eine Vorlage behandelt.

[Ollama laufende Modelle](https://docs.ollama.com/api/ps),
[Ollama GGUF-Import](https://docs.ollama.com/import),
[llama.cpp Quantisierung](https://github.com/ggml-org/llama.cpp/tree/master/tools/quantize),
[OpenClaw Ollama](https://docs.openclaw.ai/providers/ollama),
[Alertmanager-Konfiguration](https://prometheus.io/docs/alerting/latest/configuration/),
[Operator Discord-Typen](https://github.com/prometheus-operator/prometheus-operator/blob/main/pkg/apis/monitoring/v1alpha1/alertmanager_config_types.go).
Keine echte Konvertierung, Inferenz, Alertzustellung oder Cluster-Abnahme erfolgt.
