#!/bin/bash
TOOL_NAME="MLflow"
TOOL_KEY="MLflow"
TOOL_SLUG="mlflow"
TOOL_PACKAGES="mlflow"
TOOL_DESCRIPTION="Experiment-Tracking und Modell-Metadaten für Forschung und iterative Optimierung."
TOOL_OPENCLAW_NOTE="Hilft im KI_Forschung-Profil beim Tracking von Modellen, Prompts und Evaluationsläufen."
TOOL_PROMPT_EXAMPLE='```txt
Lege ein MLflow-Experiment für verschiedene Ollama-Modelle an und vergleiche Antwortqualität, Latenz und Speicherverbrauch.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
