#!/bin/bash
TOOL_NAME="Weights_and_Biases"
TOOL_KEY="Weights_and_Biases"
TOOL_SLUG="weights_and_biases"
TOOL_PACKAGES="wandb"
TOOL_DESCRIPTION="Experiment-Tracking und Vergleich von Trainingsläufen für KI-Forschung."
TOOL_OPENCLAW_NOTE="Ergänzt MLflow im KI_Forschung-Profil, wenn externes Tracking gewünscht ist."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
