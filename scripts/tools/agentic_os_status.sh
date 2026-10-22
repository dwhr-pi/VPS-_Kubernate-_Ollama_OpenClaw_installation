#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${AGENTIC_OS_PYTHON_BIN:-${OFFLOAD_SOURCE_PYTHON_BIN:-python3}}" -B "$ROOT/scripts/tools/helpers/offload_sources.py" agentic_os status "$@"
