#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
if [[ $# -eq 0 ]]; then set -- install; fi
exec "${ANTHROPIC_CLI_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/anthropic_cli.py" "$@"
