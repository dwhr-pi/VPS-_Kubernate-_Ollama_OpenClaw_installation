# Ollama Model Guide

## Modelle verwalten

Im Setup stehen jetzt zwei Wege bereit:

- `scripts/ollama_model_manager.sh`
- `scripts/ollama_model_catalog_manager.sh`

Hinweis:

- Für weitere Informationen zu einzelnen Modellen siehe in der Online-Dokumentation und im Modellkatalog nach.
- Modell-Installationen und Deinstallationen werden jetzt im Ollama Modell-Manager zeitlich mitgemessen und im Benutzer-Workspace protokolliert.

## Empfohlene Gruppen

- kleine Allrounder
- Coding-Modelle
- EU-nahe Modelle
- lokale Experimente für RAG und Agenten

Die kuratierte Übersicht findest du in [docs/OLLAMA_MODEL_CATALOG.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/OLLAMA_MODEL_CATALOG.md:1).

Die Messwerte landen hier:

- `~/.openclaw_ultimate_user_data/metrics_logs/operation_history.tsv`

## Eigene Modelle

- GGUF exportieren
- Modelfile lokal erstellen
- mit Ollama einbinden

Hilfen:

- `scripts/ollama_modelfile_assistant.sh`
- `scripts/llm_builder_project_scaffold.sh`
