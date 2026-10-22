#!/usr/bin/env bash
# Primaerquelle: https://github.com/NousResearch/hermes-agent; Umfang siehe --dry-run.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" hermes_agent_jarvis check "$@"
