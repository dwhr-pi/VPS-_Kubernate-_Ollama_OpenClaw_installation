#!/usr/bin/env bash
# Upstream: https://github.com/MiniMax-AI/MiniMax-M3; source integrity check only.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" minimax_m3 check "$@"
