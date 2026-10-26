#!/usr/bin/env bash
# Primary source: https://github.com/QwenLM/qwen-code; study/development only.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/qwen_desktop_study.py" update "$@"
