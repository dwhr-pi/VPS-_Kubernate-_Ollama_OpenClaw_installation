#!/bin/bash
TOOL_NAME="Ray"
TOOL_KEY="Ray"
TOOL_SLUG="ray"
TOOL_PACKAGES="ray[default]"
TOOL_DESCRIPTION="Verteiltes Compute-Framework für Parallelisierung, Datenverarbeitung und Agentenexperimente."
TOOL_OPENCLAW_NOTE="Passt zum KI_Forschung-Profil für größere, verteilte Laufzeit- und Trainingsjobs."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
