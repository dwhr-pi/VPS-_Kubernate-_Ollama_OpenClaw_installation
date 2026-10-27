#!/usr/bin/env bash
# An unverified platform stays blocked; legacy containers and data are preserved.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${NATIVE_GITHUB_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/native_github_tools.py" supabase doctor "$@"
