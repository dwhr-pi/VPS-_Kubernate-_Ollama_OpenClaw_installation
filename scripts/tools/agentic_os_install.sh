#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
if [[ $# -eq 0 ]]; then set -- install; fi
exec "${AGENTIC_OS_PYTHON_BIN:-${OFFLOAD_SOURCE_PYTHON_BIN:-python3}}" -B "$ROOT/scripts/tools/helpers/offload_sources.py" agentic_os "$@"
