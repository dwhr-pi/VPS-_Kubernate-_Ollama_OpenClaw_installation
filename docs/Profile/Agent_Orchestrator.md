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

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten oder logisch direkt damit verwandt, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- spezieller Router-Agent als eigenes Laufzeitmodul
- dedizierte Multi-Agent-Memory-Policies
- fortgeschrittene Ergebnis-Synchronisierung über Queue/Event-Bus

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
- `ChromaDB` ergänzt die Memory-Seite für Zwischenstände und Profilwissen.

## Vergleich

### ✅ In Sync

- Task Decomposition, Multi-Agent Routing und Memory Management lassen sich mit den vorhandenen Agenten-Frameworks grundsätzlich abbilden.
- Die wichtigsten Frameworks dafür sind bereits als Tools vorhanden.

### ⚠ Missing in Setup

- Es gibt noch kein eigenes Install-/Run-Modul für einen dedizierten `Agent_Orchestrator`.
- Queue-/Event-Bus-Bausteine für robuste Synchronisierung fehlen noch.

### ❌ Missing in Docs

- Dieses Themenprofil war lokal bisher gar nicht sichtbar, obwohl die Quelle auf GitHub existierte.

## Hinweise

- Dieses Profil ist aktuell vor allem ein Rollen- und Architekturprofil.
- Für produktionsreife Orchestrierung fehlen noch Laufzeitpolicies, Persistenzregeln und Fehlerroutinen als eigene Module.
