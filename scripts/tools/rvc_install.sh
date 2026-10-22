#!/usr/bin/env bash
# Primaerquelle: https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI; Umfang siehe --dry-run.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" rvc install "$@"
