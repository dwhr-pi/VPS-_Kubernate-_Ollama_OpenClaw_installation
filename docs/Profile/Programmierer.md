# Profil: Programmierer

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Programmierer.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Programmierer.doc.md:1), `readme.md`, `docs/setup_guide.md` und `scripts/profiles/Programmierer_install.sh` zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Multi-Agent-Setup für Entwicklung, Debugging, Architektur, Sicherheit und DevOps.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `build-essential`
- Bereits als einzelne Tools installierbar:
  - Huginn unter `/opt/huginn`
  - Clawhub CLI unter `/opt/clawhub-cli`
  - symbolischer Link `/usr/local/bin/clawhub`, sofern `bin/run` vorhanden ist
  - LangGraph unter `/opt/langgraph`
  - CrewAI unter `/opt/crewai`
  - AutoGen unter `/opt/autogen`
  - Playwright unter `/opt/playwright`
  - ChromaDB unter `/opt/chromadb`
  - Code Sandbox als Kernmodul für isolierte Entwicklungs- und Ausführungs-Workflows

## Dokumentierte zusätzliche Tools

Die zuvor zusätzlich dokumentierten Entwickler- und Observability-Bausteine sind jetzt als Setup-Module oder vorhandene Tools abbildbar:

- `Docker`
- `Kubernetes`
- `K3s`
- `GitHub_API_Tooling`
- `Code_Sandbox`
- `VS_Code_Server`
- `Puppeteer`
- `Prometheus`
- `Grafana`
- `Loki`
- `OpenTelemetry`
- `Vault`
- `SQLite`
- `Postgres`
- `Weaviate`
- `Qdrant`
- `Redis`
- `RabbitMQ`
- `NATS`

## Codex-Nachbau

Aus deinem Setup ergibt sich jetzt zusätzlich ein eigener optionaler `Codex-Nachbau`-Block im `Programmierer`-Profil. Er ist bewusst separat auswählbar, damit das normale Entwicklerprofil schlank bleibt und der schwerere Coding-Agent-Stack nur bei Bedarf mitinstalliert wird.

### Kern aus deinem Setup

- `Ollama` als lokales LLM-Backend
- `Programmierer`-Profil als Entwicklergrundlage
- `OpenClaw` als Orchestrator und Tool-Schicht
- `OpenManus` oder `AutoGPT` für agentische Mehrschritt-Workflows
- `Clawbake` für Build-/Deploy-Automation
- `K3s` und `kubectl` für spätere Sandbox- oder Cluster-Workflows
- optional `Flowise` und `LangFlow` für visuelle LLM-Flows
- `Huginn`, `n8n` und `Activepieces` für umgebende Automatisierung

### Ergänzte Module für den Nachbau

Diese Bausteine sind jetzt im Setup als einzelne Tools hinterlegt und über `Programmierer -> Codex-Nachbau` auswählbar. Zusätzlich gibt es dort jetzt auch eine Komplettaktion, um den ganzen Block in einem Schritt zu installieren oder wieder zu entfernen.

- `Aider`
- `OpenCode`
- `OpenHands`
- `GitHub_CLI`
- `Podman`
- ergänzend die bereits vorhandenen Bausteine `Docker`, `K3s`, `Clawbake` und `Ollama`

Wo sinnvoll, werden die neuen Bausteine direkt aus GitHub-Quellen geholt und lokal auf dem Zielsystem vorbereitet oder gebaut.

### Empfohlener Stack

```text
Ollama
+ qwen3-coder:30b oder devstral:24b
+ OpenCode oder Aider als CLI-Coding-Agent
+ OpenHands für größere Sandbox-Agentenläufe
+ Docker/Podman Sandbox
+ GitHub CLI
+ OpenClaw als Orchestrator
+ Clawbake für Build/Test/Deploy
+ K3s für spätere VPS-/Cluster-Sandbox
```

### Empfohlene Ollama-Modelle

```bash
ollama pull mixtral
ollama pull codestral
ollama pull qwen3-coder:30b
ollama pull devstral:24b
ollama pull qwen2.5-coder:7b
```

## Plattformabdeckung des Codex-Nachbaus

Mit dem aktuellen Stack sind vor allem diese Zielsysteme sinnvoll bedienbar:

- Linux
- Windows
- Web- und API-Projekte
- Container- und Serverdienste
- allgemeine Python-, Node-, Go- und Multi-Repo-Projekte

Mit zusaetzlichen Toolchains ebenfalls gut denkbar:

- Android mit Android SDK, Gradle, Flutter oder React Native
- ESP32 mit PlatformIO oder ESP-IDF
- Arduino mit Arduino CLI oder PlatformIO

Wichtige Grenze:

- iPhone- und macOS-Nativbuilds lassen sich fachlich vorbereiten, analysieren und grossteils generieren, der finale Build, die Signierung und der App-Store-/TestFlight-Weg brauchen aber weiterhin ein echtes macOS-/Xcode-System

Empfehlung:

- `qwen3-coder:30b` als Hauptmodell für lokale agentische Coding-Aufgaben
- `devstral:24b` als starke Alternative oder Fallback
- `codestral:22b` als fokussiertes Mistral-Coding-Modell
- `mixtral:8x7b` als allgemeiner Planungs-, Review- oder Hauptagent
- `qwen2.5-coder:7b` als leichtere Ergänzung für kleinere Maschinen oder VPS

### Beispiel-Nutzung

```txt
Nutze den Codex-Nachbau-Block mit Ollama, Aider und GitHub CLI. Analysiere mein Repository, schlage einen minimalen Patch vor, erkläre den Diff und bereite einen sauberen Branch-Workflow für einen späteren Pull Request vor.
```

```txt
Nutze OpenHands mit einer lokalen Sandbox und devstral:24b, um eine mehrstufige Setup-Reparatur zu planen, den Fix zu schreiben und die wichtigsten Risiken für Build, Repo-Zustand und Deployment zusammenzufassen.
```

## Verantwortlichkeiten

- Entwicklungsnahe Automatisierung
- CLI-gestützte Agenten-Interaktion
- Web-Workflow-Orchestrierung über Huginn
- Architekturentscheidungen für verteilte Systeme
- Debugging, Review und Security-Härtung
- OpenClaw- und Ollama-orientierte Agentenkoordination

## Verfügbare Kommandos

```bash
scripts/tools/huginn_install.sh
scripts/tools/clawhub_cli_install.sh
scripts/tools/langgraph_install.sh
scripts/tools/crewai_install.sh
scripts/tools/autogen_install.sh
scripts/tools/playwright_install.sh
scripts/tools/chromadb_install.sh
RAILS_ENV=production bundle exec rails server -p 3000
clawhub
```

## Vollständige Prompt-Liste

### Core Developer Agent

```txt
Du bist ein Senior Software Engineer. Schreibe sauberen, produktionsreifen Code mit Fokus auf Skalierbarkeit und Wartbarkeit.
Erkläre jede Architekturentscheidung kurz, bevor du Code generierst.
Nutze Best Practices (SOLID, DRY, KISS) automatisch.
Wenn Anforderungen unklar sind, stelle Rückfragen statt zu raten.
```

### Debugging Agent

```txt
Du bist ein Debugging-Spezialist. Analysiere Logs, Stacktraces und Fehler systematisch.
Identifiziere Root Cause statt Symptome.
Gib konkrete Fixes + minimalen Patch-Code aus.
Bewerte mögliche Nebenwirkungen deiner Lösung.
```

### System Architecture Agent

```txt
Du bist Systemarchitekt für verteilte Systeme (Kubernetes, VPS, Microservices).
Zerlege Systeme in Module und beschreibe Datenflüsse.
Schlage skalierbare Architekturvarianten vor.
Berücksichtige Latency, Cost und Failure Points.
```

### Code Review Agent

```txt
Du bist ein strenger Code-Reviewer.
Finde Bugs, Security Issues, Performance-Probleme.
Gib konkrete Verbesserungsvorschläge mit Diff-Style Änderungen.
Bewerte Codequalität von 1–10 und begründe objektiv.
```

### Security Agent

```txt
Du bist Security Engineer für AI-Agents und Cloud-Systeme.
Analysiere Code auf Injection, RCE, Credential Leaks.
Bewerte API-Sicherheit und Tool-Execution Risiken.
Schlage Hardening-Maßnahmen vor (Sandbox, RBAC, Audit Logs).
```

### DevOps / Kubernetes Agent

```txt
Du bist DevOps Engineer für Docker, VPS und Kubernetes.
Erstelle Deployment-YAMLs und Helm Charts.
Optimiere Container für Performance und Stabilität.
Erkenne Bottlenecks in Cluster-Architektur.
```

### AI Integration Agent

```txt
Du bist Spezialist für lokale LLM-Systeme (Ollama, OpenClaw).
Optimiere Prompt Routing zwischen lokalen und Cloud-Modellen.
Minimiere Token-Kosten durch intelligente Task-Splitting.
Wähle Modelle basierend auf Aufgabe.
```

### Performance Optimizer Agent

```txt
Analysiere System-Performance (CPU, RAM, GPU, Latenz).
Finde Engpässe in AI Pipelines.
Optimiere Throughput und Context Window Nutzung.
```

## Beispiel-Nutzung im OpenClaw-Setup

### Architektur-Review mit lokalem Ollama-Modell

```txt
Nutze den System Architecture Agent. Analysiere mein OpenClaw-Deployment auf VPS und MiniPC.
Zerlege die Komponenten in Gateway, Ollama, Workflow-Engine, Persistenz und externe Integrationen.
Gib mir eine Zielarchitektur mit klaren Datenflüssen, Failure Points und konkreten Verbesserungen.
```

### Code-Debugging mit Agentenrolle

```txt
Nutze den Debugging Agent. Analysiere den Fehler im Setup-Skript, identifiziere die Root Cause
und gib mir einen minimalen Patch für Bash aus. Berücksichtige Node.js-, pnpm- und OpenClaw-Abhängigkeiten.
```

### Security-Check für Tool-Ausführung

```txt
Nutze den Security Agent. Prüfe mein OpenClaw- und Ollama-Setup auf offene Ports, unsichere Tool-Calls,
fehlende Sandbox-Isolation und Secret-Leaks. Schlage konkrete Hardening-Maßnahmen für VPS und lokale Dienste vor.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu lokalem Ollama als primärem Modell-Backend und OpenClaw als Agenten- und Tool-Orchestrierungsschicht.
- Besonders passend ist die Kombination aus `LangGraph`, `CrewAI` und `AutoGen` für mehrstufige Planer-, Coder-, Reviewer- und Ops-Agenten.
- `Playwright` ergänzt Browser-Automation und UI-Checks.
- `ChromaDB` passt als lokale Memory- und Retrieval-Schicht für agentische Entwicklungsworkflows.
- Für Coding-Aufgaben ist zusätzlich ein spezialisiertes Ollama-Modell sinnvoll, das aktuell noch manuell gewählt und installiert werden muss.

## Vergleich

### ✅ In Sync

- Huginn ist sowohl dokumentiert als auch script-seitig eingebunden.
- Clawhub CLI ist sowohl im Menü als auch im Profilskript enthalten.
- `LangGraph`, `CrewAI`, `AutoGen`, `Playwright` und `ChromaDB` sind jetzt als einzelne Tools vorhanden.
- Die wichtigsten agentischen Entwicklungsbausteine aus der Quelldatei sind damit praktisch nutzbar.
- Der `Codex-Nachbau` ist jetzt als eigener optionaler Profilblock mit `Aider`, `OpenCode`, `OpenHands`, `GitHub_CLI` und `Podman` auswählbar.

### ⚠ Missing in Setup

- Die zuvor fehlenden DevOps-, Observability- und Queue-Bausteine sind jetzt im Setup vorhanden.
- Ein dediziertes Coding-Modell für Ollama wird weiterhin nicht automatisch mit einem Profil ausgerollt.
- Die empfohlenen Ollama-Modelle werden weiterhin bewusst über den Ollama-Modell-Manager oder manuelle `ollama pull`-Kommandos installiert.

### ❌ Missing in Docs

- Die konkrete CLI-Verlinkung nach `/usr/local/bin/clawhub` ist in der allgemeinen Projektdoku nur am Rand sichtbar.

## Hinweise

- Huginn benötigt weiterhin manuelle `.env`-Anpassung und einen manuellen Start.
- Standardport von Huginn ist `3000` und kollidiert potenziell mit OpenClaw, Flowise, Activepieces und Zenbot.
- Für das volle Zielbild bleiben vor allem Modellwahl, konkrete Sandbox-Strategie und projektabhängige Startkommandos als bewusste Feinarbeit beim Nutzer.
- Falls bei einem Git-Clone überhaupt ein GitHub-Username abgefragt wird, ist damit dein eigener GitHub-Benutzer gemeint. Das sollte nur bei privaten oder geschützten Repositories nötig sein; öffentliche Repositories sollten ohne Login klonen.
