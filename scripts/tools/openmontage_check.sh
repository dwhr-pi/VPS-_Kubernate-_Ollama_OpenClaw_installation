#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${OPENMONTAGE_INSTALLER_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/openmontage.py" check "$@"
