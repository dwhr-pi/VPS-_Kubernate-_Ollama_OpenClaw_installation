#!/usr/bin/env bash
# Upstream: https://github.com/bwendell/gemini-desktop; study sources only, not Gemini CLI or an OpenClaw adapter.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" gemini_desktop_bwendell_source uninstall "$@"
