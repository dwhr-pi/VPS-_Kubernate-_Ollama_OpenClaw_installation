#!/bin/bash
set -euo pipefail
TOOL_NAME="Browser Use"
TOOL_KEY="Browser_Use"
TOOL_SLUG="browser_use"
TOOL_PACKAGES="browser-use playwright"
TOOL_POST_INSTALL="python -m playwright install chromium"
TOOL_DESCRIPTION="Lokales Browser-Agent-Toolkit für Web-Automatisierung, Navigation, Formulare und agentische Browser-Workflows."
TOOL_OPENCLAW_NOTE="Passt zu Browser-Agent-, Research- und Sandbox-Profilen. Browser-Zugriffe nur bewusst mit vertrauenswürdigen Zielen verwenden."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
