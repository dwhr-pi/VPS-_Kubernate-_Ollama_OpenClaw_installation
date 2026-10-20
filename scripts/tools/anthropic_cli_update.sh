#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${ANTHROPIC_CLI_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/anthropic_cli.py" update "$@"
