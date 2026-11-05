#!/usr/bin/env bash
# Offline source-integrity check; not a runtime acceptance claim.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -I -B "$ROOT/scripts/documentation_server/lifecycle.py" status "$@"
