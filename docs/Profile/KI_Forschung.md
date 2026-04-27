# Profil: KI_Forschung

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [KI_Forschung.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/KI_Forschung.doc.md:1), `readme.md`, `docs/setup_guide.md` und `scripts/profiles/KI_Forschung_install.sh` zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Forschungsprofil für Recherche, Paper-Analyse, Hypothesenbildung, RAG und experimentelle Agenten-Workflows.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - OpenClaw RL unter `/opt/openclaw-rl`
  - Flowise unter `/opt/flowise`
  - LangFlow unter `/opt/langflow`
  - LangChain unter `/opt/langchain`
  - LlamaIndex unter `/opt/llamaindex`
  - MLflow unter `/opt/mlflow`
  - Whisper unter `/opt/whisper`

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- Chroma
- Weaviate
- CrewAI
- AutoGPT
- Weights & Biases
- vLLM
- llama.cpp
- Stable Diffusion
- Ray
- EnviroLLM

## Verantwortlichkeiten

- Deep Research und Themenanalyse
- Paper-Review und Reproduzierbarkeitsprüfung
- Hypothesen- und Ideenfindung
- Modell- und Methodenvergleich
- RAG-gestützte Wissensextraktion
- Forschungsnahe Multi-Agent-Workflows

## Verfügbare Kommandos

```bash
scripts/tools/openclaw_rl_install.sh
scripts/tools/flowise_install.sh
scripts/tools/langflow_install.sh
scripts/tools/langchain_install.sh
scripts/tools/llamaindex_install.sh
scripts/tools/mlflow_install.sh
scripts/tools/whisper_install.sh
```

## Vollständige Prompt-Liste

### Deep Research Prompts

```txt
SYSTEM:
Du bist ein KI-Forschungsassistent mit Zugriff auf lokale Modelle, Dokumente und Webdaten.

USER:
Analysiere das Thema: {THEMA}

Aufgaben:
1. Aktueller Stand der Forschung (2024–2026)
2. Key Papers & Durchbrüche
3. Offene Probleme
4. Zukunftstrends (3–5 Jahre)
5. Eigene Hypothesen / Ideen
```

### Paper-Analyse

```txt
Analysiere dieses Paper:

- Kurz-Zusammenfassung
- Methodik
- Stärken / Schwächen
- Reproduzierbarkeit
- Neuheit
```

### Hypothesen Generator

```txt
Generiere 10 Forschungs-Hypothesen zu: {THEMA}
```

### Self Improving Agent

```txt
Analysiere → löse → kritisiere → verbessere (3 Iterationen)
```

### Multi Agent Debate

```txt
Simuliere:
- Researcher
- Engineer
- Reviewer

Diskutiere: {THEMA}
```

### Vergleich Prompt

```txt
Vergleiche Modelle nach:
- Reasoning
- Speed
- Memory
- Kosten
```

### RAG Knowledge Extraction

```txt
Extrahiere Key Insights + Knowledge Graph Struktur
```

## Beispiel-Nutzung im OpenClaw-Setup

### Themen-Recherche mit RAG

```txt
Nutze den Deep Research Prompt. Analysiere das Thema: lokales Multi-Agent-Routing mit Ollama und OpenClaw.
Liefere Forschungsstand, zentrale Papers, offene Probleme, Zukunftstrends und eigene Hypothesen.
Nutze vorhandene Dokumente und Webdaten strukturiert.
```

### Paper-Review

```txt
Nutze den Paper-Analyse Prompt. Analysiere dieses Paper auf Kurz-Zusammenfassung, Methodik,
Stärken, Schwächen, Reproduzierbarkeit und Neuheit. Gib am Ende eine Einschätzung,
ob das Paper für mein OpenClaw-Forschungssetup praktisch relevant ist.
```

### Modellvergleich

```txt
Nutze den Vergleich Prompt. Vergleiche meine verfügbaren Modelle nach Reasoning, Speed,
Memory und Kosten und gib eine Empfehlung für Research, Coding und Agentensteuerung.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw als Forschungs-Orchestrator und Ollama als lokaler Modellschicht.
- `LangChain` und `LlamaIndex` sind die wichtigsten aktuell installierbaren RAG-Bausteine.
- `Flowise` und `LangFlow` unterstützen visuelle Forschungs- und Agentenflüsse.
- `MLflow` und `Whisper` ergänzen Experiment-Tracking und Sprachverarbeitung.
- Für das Zielbild aus der Quelldatei fehlen noch mehrere skalierende und multimodale Module.

## Vergleich

### ✅ In Sync

- `OpenClaw RL`, `Flowise` und `LangFlow` sind eingebunden.
- `LangChain`, `LlamaIndex`, `MLflow` und `Whisper` sind als einzelne Tools vorhanden.
- Die RAG- und Forschungsgrundlage aus der Quelldatei ist damit teilweise praktisch nutzbar.

### ⚠ Missing in Setup

- `Chroma` und `Weaviate` sind dokumentiert, aber in diesem Profil nicht beide als Forschungsoption umgesetzt.
- `CrewAI`, `AutoGPT`, `Weights & Biases`, `vLLM`, `llama.cpp`, `Stable Diffusion`, `Ray` und `EnviroLLM` fehlen noch als installierbare Module.
- Forschungsmodelle wie `gemini-1.5-pro` oder andere externe Spezialmodelle werden nicht automatisch provisioniert.

### ❌ Missing in Docs

- Die visuelle Abgrenzung zwischen Forschungsprofil und allgemeinem Tool-Menü ist in der Hauptdoku noch schwach.

## Hinweise

- `Flowise` und `LangFlow` werden nicht vollständig als dauerhafte Services provisioniert.
- Portkonflikte mit `3000` und `7860` bleiben relevant.
- Für ernsthafte Forschungs-Pipelines fehlen noch mehrere in der Quelldatei genannte Skalierungs- und Tracking-Bausteine.
