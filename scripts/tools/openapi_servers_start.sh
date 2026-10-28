#!/usr/bin/env bash
# Explicit configuration/start only; never run automatically by installation.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/openapi_servers_runtime.py" start "$@"
