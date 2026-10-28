#!/usr/bin/env bash
# Primary source: https://github.com/godotengine/godot; explicit optional scope, no GUI/XR start.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" godot_source update "$@"
