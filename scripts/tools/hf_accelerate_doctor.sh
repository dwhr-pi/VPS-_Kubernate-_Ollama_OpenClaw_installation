#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${OFFLOAD_SOURCE_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/offload_sources.py" hf_accelerate doctor "$@"
