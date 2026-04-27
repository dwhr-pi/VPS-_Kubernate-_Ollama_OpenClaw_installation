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

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- Docker
- Kubernetes
- k3s
- GitHub API Tooling
- Code Execution Sandbox
- VS Code Server
- Puppeteer
- Prometheus
- Grafana
- Loki
- OpenTelemetry
- Vault / Secrets Management
- SQLite / Postgres
- Weaviate
- Qdrant
- Redis
- RabbitMQ
- NATS

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

### ⚠ Missing in Setup

- Ein dediziertes Coding-Modell für Ollama wird nicht automatisch installiert.
- Docker, Kubernetes-spezifische Helfer, GitHub API Tooling und eine echte Code-Sandbox sind noch nicht als eigene Tool-Skripte ergänzt.
- Observability- und Security-Bausteine wie `Prometheus`, `Grafana`, `Loki`, `OpenTelemetry` und `Vault` sind aktuell nur dokumentiert.
- Die dokumentierten Memory- und Queue-Alternativen `Weaviate`, `Qdrant`, `Redis`, `RabbitMQ` und `NATS` fehlen noch als installierbare Module.

### ❌ Missing in Docs

- Die konkrete CLI-Verlinkung nach `/usr/local/bin/clawhub` ist in der allgemeinen Projektdoku nur am Rand sichtbar.

## Hinweise

- Huginn benötigt weiterhin manuelle `.env`-Anpassung und einen manuellen Start.
- Standardport von Huginn ist `3000` und kollidiert potenziell mit OpenClaw, Flowise, Activepieces und Zenbot.
- Für das volle Zielbild aus der Quelldatei fehlen noch mehrere Infra- und Observability-Module als echte Install-/Uninstall-Skripte.
