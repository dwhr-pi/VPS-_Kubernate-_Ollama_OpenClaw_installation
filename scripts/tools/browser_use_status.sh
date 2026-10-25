#!/usr/bin/env bash
# Primary source: https://github.com/browser-use/browser-use; pinned build, no browser/API/server start.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" browser_use status "$@"
