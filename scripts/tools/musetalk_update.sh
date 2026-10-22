#!/usr/bin/env bash
# Primaerquelle: https://github.com/TMElyralab/MuseTalk; Umfang siehe --dry-run.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" musetalk update "$@"
