#!/usr/bin/env bash
# Upstream: https://github.com/SeaDve/Mousai; source preparation only.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" mousai uninstall "$@"
