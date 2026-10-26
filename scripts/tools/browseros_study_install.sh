#!/usr/bin/env bash
# Primary source: https://github.com/browseros-ai/BrowserOS; study/development only.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/browseros_study.py" install "$@"
