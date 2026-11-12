#!/usr/bin/env bash
# Unreleased research guard; no download, installation or runtime claim.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/unreleased_research.py" songsage install "$@"
