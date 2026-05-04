#!/bin/bash
set -euo pipefail
TOOL_NAME="LM Evaluation Harness"
TOOL_KEY="LM_Evaluation_Harness"
TOOL_SLUG="lm_evaluation_harness"
TOOL_PACKAGES="lm-eval[hf]"
TOOL_DESCRIPTION="Benchmark-Framework für lokale und API-basierte Sprachmodelle mit reproduzierbaren Standardaufgaben."
TOOL_OPENCLAW_NOTE="Geeignet für Modellvergleiche mit Ollama, LiteLLM und Offline-Evaluationsläufen."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
