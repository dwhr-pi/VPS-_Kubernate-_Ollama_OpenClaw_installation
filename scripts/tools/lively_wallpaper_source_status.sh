#!/usr/bin/env bash
# Primary source: https://github.com/lively-community/lively; read-only inventory, no engine start.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" lively_wallpaper_source status "$@"
