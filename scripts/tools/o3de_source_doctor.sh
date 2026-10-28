#!/usr/bin/env bash
# Primary source: https://github.com/o3de/o3de; explicit optional scope, no GUI/XR start.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" o3de_source doctor "$@"
