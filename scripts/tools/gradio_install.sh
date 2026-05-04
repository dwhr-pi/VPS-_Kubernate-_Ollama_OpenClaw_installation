#!/bin/bash
set -euo pipefail
TOOL_NAME="Gradio"
TOOL_KEY="Gradio"
TOOL_SLUG="gradio"
TOOL_PACKAGES="gradio"
TOOL_DESCRIPTION="Einfaches UI-Toolkit für Demo-Oberflächen, Modellprototypen und lokale Interaktions-Apps."
TOOL_OPENCLAW_NOTE="Sinnvoll für schnelle Modell- und Agenten-Demos auf localhost."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
