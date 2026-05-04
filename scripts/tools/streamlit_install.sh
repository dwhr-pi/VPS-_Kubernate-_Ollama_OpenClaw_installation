#!/bin/bash
set -euo pipefail
TOOL_NAME="Streamlit"
TOOL_KEY="Streamlit"
TOOL_SLUG="streamlit"
TOOL_PACKAGES="streamlit"
TOOL_DESCRIPTION="Schnelles Python-UI-Framework für interne Dashboards, Prototypen und lokale KI-Apps."
TOOL_OPENCLAW_NOTE="Nützlich für App-Builder, BI-Profile und lokale Agenten-Frontends."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
