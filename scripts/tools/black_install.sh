#!/bin/bash
set -euo pipefail
TOOL_NAME="Black"
TOOL_KEY="Black"
TOOL_SLUG="black"
TOOL_PACKAGES="black"
TOOL_DESCRIPTION="Python-Formatter für konsistente Code-Basis in Agenten-, Eval- und Datenprojekten."
TOOL_OPENCLAW_NOTE="Sinnvoll für Python-lastige Profile, lokale Agenten-Repos und CI-Vorbereitung."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
