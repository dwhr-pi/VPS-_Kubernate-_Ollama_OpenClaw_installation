# Profil: Agent_Orchestrator

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Agent_Orchestrator.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Agent_Orchestrator.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Koordinationsprofil für Mehragentensysteme, Aufgabenzerlegung und Ergebnis-Synchronisierung.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - LangGraph unter `/opt/langgraph`
  - CrewAI unter `/opt/crewai`
  - AutoGen unter `/opt/autogen`
  - ChromaDB unter `/opt/chromadb`
  - Redis systemweit
  - NATS unter `/opt/nats`
  - Qdrant unter `/opt/qdrant`
  - Weaviate unter `/opt/weaviate`
  - Prometheus unter `/opt/prometheus`
  - Grafana unter `/opt/grafana`
  - Loki unter `/opt/loki`

## Dokumentierte zusätzliche Tools

Die zuvor nur fachlich beschriebenen Bausteine sind jetzt als eigene Setup-Module vorhanden:

- `Agent_Router`
- `Memory_Policies`

## Verantwortlichkeiten

- große Aufgaben zerlegen
- spezialisierte Profile oder Agenten auswählen
- Zwischenergebnisse zusammenführen
- Memory und Kontext zwischen Agenten koordinieren

## Verfügbare Kommandos

```bash
scripts/tools/langgraph_install.sh
scripts/tools/crewai_install.sh
scripts/tools/autogen_install.sh
scripts/tools/chromadb_install.sh
scripts/tools/redis_install.sh
scripts/tools/nats_install.sh
scripts/tools/qdrant_install.sh
scripts/tools/weaviate_install.sh
scripts/tools/prometheus_install.sh
scripts/tools/grafana_install.sh
scripts/tools/loki_install.sh
```

## Beispielprompts

### Orchestrator Core

```txt
Du bist ein Agent Orchestrator.
Zerlege die Aufgabe in Teilaufgaben, weise passende Spezialagenten zu,
koordiniere die Reihenfolge der Ausführung und führe die Ergebnisse am Ende konsistent zusammen.
```

### Routing Prompt

```txt
Analysiere die folgende Aufgabe und entscheide, ob sie an Programmierer, KI_Forschung,
Texter_Werbung_Marketing, Media_Musik oder Rechtsberatung_Steuerrecht delegiert werden soll.
Begründe die Auswahl und gib die Übergabedaten je Agent an.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt direkt zur Orchestrierungsrolle von OpenClaw.
- `LangGraph`, `CrewAI` und `AutoGen` sind die naheliegendsten bereits vorhandenen Bausteine.
- `ChromaDB`, `Qdrant` und `Weaviate` ergänzen die Memory-Seite für Zwischenstände und Profilwissen.
- `Redis` und `NATS` bilden jetzt die Queue-/Event-Bus-Bausteine für Synchronisierung.
- `Prometheus`, `Grafana` und `Loki` decken den Observability-Teil ab.

## Vergleich

### ✅ In Sync

- Task Decomposition, Multi-Agent Routing und Memory Management lassen sich mit den vorhandenen Agenten-Frameworks grundsätzlich abbilden.
- Die wichtigsten Frameworks dafür sind bereits als Tools vorhanden.
- Queue-/Event-Bus- und Observability-Bausteine sind jetzt als installierbare Module vorhanden.

### ⚠ Missing in Setup

- Die zuvor fehlenden Orchestrierungsbausteine sind jetzt als einzelne Module im Setup vorhanden.
- Offen bleibt produktives Feintuning für konkrete Routing-, Retry- und Dead-Letter-Regeln.

### ❌ Missing in Docs

- Dieses Themenprofil war lokal bisher gar nicht sichtbar, obwohl die Quelle auf GitHub existierte.

## Hinweise

- Dieses Profil ist aktuell vor allem ein Rollen- und Architekturprofil.
- Für produktionsreife Orchestrierung fehlen noch Laufzeitpolicies, Persistenzregeln und Fehlerroutinen als eigene Module.
