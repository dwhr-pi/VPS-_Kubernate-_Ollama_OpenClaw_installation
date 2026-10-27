#!/usr/bin/env bash
# Quelle: https://github.com/supabase/supabase; see config/docker_to_github.json.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${NATIVE_GITHUB_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/native_github_tools.py" supabase install "$@"
