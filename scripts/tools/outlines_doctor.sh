#!/usr/bin/env bash
# Upstream: https://github.com/dottxt-ai/outlines; source preparation only, no runtime or start.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" outlines doctor "$@"
