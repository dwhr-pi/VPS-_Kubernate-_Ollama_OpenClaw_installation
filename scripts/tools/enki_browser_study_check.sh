#!/usr/bin/env bash
# Primary source: https://github.com/danilogiles/enki-browser; study/development only.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/enki_browser_study.py" check "$@"
