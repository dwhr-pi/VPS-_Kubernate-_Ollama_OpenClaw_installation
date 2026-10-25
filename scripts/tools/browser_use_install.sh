#!/bin/bash
set -euo pipefail
TOOL_NAME="Browser Use"
TOOL_KEY="Browser_Use"
TOOL_SLUG="browser_use"
TOOL_SOURCE="https://github.com/browser-use/browser-use"
TOOL_DESCRIPTION="Lokales Browser-Agent-Toolkit für Web-Automatisierung, Navigation, Formulare und agentische Browser-Workflows."
TOOL_OPENCLAW_NOTE="Passt zu Browser-Agent-, Research- und Sandbox-Profilen. Browser-Zugriffe nur bewusst mit vertrauenswürdigen Zielen verwenden."
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" browser_use install "$@"
