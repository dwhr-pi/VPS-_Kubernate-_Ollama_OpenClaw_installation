# Profil: Prompt_Engineering_Studio

## Zweck

Prompt-Bibliotheken, Systemprompt-Pflege, Modellvergleiche, Prompt-Regressionen und Evaluationssets fuer Ollama/OpenClaw/LiteLLM.

## Installierbare Kern-Tools

- `promptfoo`
- `litellm`
- `langfuse`
- `openlit`
- `open_webui`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `DeepEval`, `Ragas`, Markdown-Prompt-Registry, Datasets pro Team

## Hardware / Plattform

- gut fuer `WSL2`, `VPS`, `GPU-Workstation`
- GPU erst fuer groessere lokale Modelle relevant

## Risiken und Grenzen

- Prompt- und Eval-Daten koennen interne Inhalte enthalten
- Traces und Telemetrie nur datensparsam speichern

## Quickstart

```bash
bash scripts/profiles/Prompt_Engineering_Studio_install.sh
```
