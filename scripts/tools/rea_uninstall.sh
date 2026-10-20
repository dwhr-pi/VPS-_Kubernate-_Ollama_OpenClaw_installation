#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${REA_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/rea_source.py" uninstall "$@"
