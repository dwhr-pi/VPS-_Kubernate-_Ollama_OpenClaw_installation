# Profil: KI_Forschung

## Überblick

Dieses Profil richtet sich an RL- und LLM-Experimentier-Workflows.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `python3-venv`
- Profil-Tooling:
  - OpenClaw RL unter `/opt/openclaw-rl`
  - Flowise unter `/opt/flowise`
  - LangFlow unter `/opt/langflow`
  - LangChain unter `/opt/langchain`
  - LlamaIndex unter `/opt/llamaindex`
  - MLflow unter `/opt/mlflow`
  - Whisper unter `/opt/whisper`

## Verantwortlichkeiten

- Reinforcement-Learning-Experimente
- visuelle LLM-Workflow-Erstellung
- OpenClaw-nahe Forschung und Prototyping

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

## Beispielprompts

### Deep Research

```txt
SYSTEM:
Du bist ein KI-Forschungsassistent mit Zugriff auf lokale Modelle, Dokumente und Webdaten.

USER:
Analysiere das Thema: {THEMA}

Aufgaben:
1. Aktueller Stand der Forschung
2. Key Papers und Durchbrüche
3. Offene Probleme
4. Zukunftstrends
5. Eigene Hypothesen
```

### Paper-Analyse

```txt
Analysiere dieses Paper:
- Kurz-Zusammenfassung
- Methodik
- Stärken und Schwächen
- Reproduzierbarkeit
- Neuheit
```

## OpenClaw / Ollama Fit

- OpenClaw eignet sich hier als Orchestrator zwischen Research-Agent, Critic-Agent und Retrieval-Layer.
- Die neuen Tools stärken vor allem RAG, Experiment-Tracking und Audio-/Speech-Auswertung.

## Vergleich

### ✅ In Sync

- OpenClaw RL ist sauber im Profil verankert.
- Flowise und LangFlow sind sowohl in Doku als auch im Profilskript vorgesehen.
- LangChain, LlamaIndex, MLflow und Whisper sind jetzt als installierbare Ergänzungen vorhanden.

### ⚠ Missing in Setup

- Kein automatisches `gemini-1.5-pro`-Setup
- Keine breitere ML-Bibliotheksauswahl wie TensorFlow oder PyTorch
- vLLM, Ray, Stable Diffusion und EnviroLLM aus der Quelldatei sind noch nicht als Tool-Skripte umgesetzt.

### ❌ Missing in Docs

- Keine dedizierte Profil-Datei im ursprünglichen Repo

## Hinweise

- Flowise nutzt standardmäßig Port `3000`.
- LangFlow nutzt standardmäßig Port `7860`.
- Port-3000-Kollisionen mit OpenClaw, Huginn, Activepieces und Zenbot sind wahrscheinlich.
