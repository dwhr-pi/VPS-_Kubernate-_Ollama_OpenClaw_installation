#!/bin/bash
set -euo pipefail
TOOL_NAME="DVC"
TOOL_KEY="DVC"
TOOL_SLUG="dvc"
TOOL_PACKAGES="dvc"
TOOL_DESCRIPTION="Data Version Control für Datensätze, Modelle, Pipelines und reproduzierbare ML-/RAG-Artefakte."
TOOL_OPENCLAW_NOTE="Sinnvoll für Dataset-Kuration, Fine-Tuning und reproduzierbare Evaluationsläufe."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
