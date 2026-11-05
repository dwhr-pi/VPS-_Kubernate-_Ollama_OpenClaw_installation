#!/usr/bin/env bash
# Source: https://github.com/openutau/OpenUtau; source-only, no runtime acceptance.
# Pinned GitHub audio tool; no GUI, models, inference, services or Docker.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" openutau status "$@"
