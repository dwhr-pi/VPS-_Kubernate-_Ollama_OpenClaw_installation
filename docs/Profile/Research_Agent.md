# Profil: Research_Agent

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Research_Agent.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Research_Agent.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Rechercheprofil für GitHub-Analyse, Doku-Verständnis und Tool-/Repo-Evaluierung.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - Playwright unter `/opt/playwright`
  - LangChain unter `/opt/langchain`
  - LlamaIndex unter `/opt/llamaindex`
  - ChromaDB unter `/opt/chromadb`

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten oder logisch direkt damit verwandt, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- dedizierte GitHub-Analyse als eigenes Profil-Tool
- Trend-Erkennung über externe Datenquellen
- automatisierte Repo-Vergleichspipelines

## Verantwortlichkeiten

- neue Tools und Repositories untersuchen
- Dokumentation systematisch auswerten
- Verbesserungspotenziale im Setup identifizieren
- Rechercheergebnisse strukturiert aufbereiten

## Verfügbare Kommandos

```bash
scripts/tools/playwright_install.sh
scripts/tools/langchain_install.sh
scripts/tools/llamaindex_install.sh
scripts/tools/chromadb_install.sh
```

## Beispielprompts

### Repo-Analyse

```txt
Analysiere das angegebene GitHub-Repository.
Untersuche Struktur, Dokumentation, Tooling, Risiken und Verbesserungspotenziale
und gib mir eine priorisierte Zusammenfassung.
```

### Tool-Recherche

```txt
Finde geeignete Tools für mein OpenClaw- und Ollama-Setup.
Begründe Nutzen, Integrationsaufwand und welches Profil am meisten davon profitiert.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw als koordinierendem Recherche-Agenten.
- `Playwright` eignet sich für Browser- und UI-nahe Recherche.
- `LangChain`, `LlamaIndex` und `ChromaDB` helfen bei Doku-Auswertung, Notizen und Retrieval.

## Vergleich

### ✅ In Sync

- Die Kernrollen Recherche, Doku-Verständnis und Setup-Verbesserung lassen sich mit den vorhandenen Bausteinen gut abbilden.
- Die wichtigsten RAG- und Browser-Werkzeuge sind schon installierbar.

### ⚠ Missing in Setup

- Es gibt noch kein eigenes Laufzeitmodul nur für `Research_Agent`.
- Externe Trend- und Repo-Monitoring-Bausteine fehlen noch als dedizierte Tools.

### ❌ Missing in Docs

- Dieses Profil war lokal bislang noch nicht als eigene Zielseite vorhanden.

## Hinweise

- Das Profil ist aktuell stärker rollen- und workfloworientiert als produktionsfertig automatisiert.
