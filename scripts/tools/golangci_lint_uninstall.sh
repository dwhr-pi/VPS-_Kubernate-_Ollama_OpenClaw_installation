#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${DEV_QUALITY_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/development_go.py" golangci_lint uninstall "$@"
