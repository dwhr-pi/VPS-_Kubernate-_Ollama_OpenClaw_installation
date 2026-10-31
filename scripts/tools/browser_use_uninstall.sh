#!/bin/bash
# Primary source: https://github.com/browser-use/browser-use
set -euo pipefail
# Metadata and lifecycle tracking are owned by gap_tools.py.
# TOOL_NAME="Browser Use"
# TOOL_KEY="Browser_Use"
# TOOL_SLUG="browser_use"
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" browser_use uninstall "$@"
