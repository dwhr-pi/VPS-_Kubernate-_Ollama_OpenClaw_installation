#!/usr/bin/env bash
# Upstream: https://github.com/levo-demo/LeVo; source preparation only.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" levo_2 install "$@"
