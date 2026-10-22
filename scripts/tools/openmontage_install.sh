#!/usr/bin/env bash
# Primaerquelle: https://github.com/calesthio/OpenMontage (gepinnt im Helper).
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${OPENMONTAGE_INSTALLER_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/openmontage.py" install "$@"
