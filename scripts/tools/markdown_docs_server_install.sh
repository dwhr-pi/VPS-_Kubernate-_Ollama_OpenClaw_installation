#!/usr/bin/env bash
# Native GitHub sources only; installing never starts the server.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
APPLY=false
for ARG in "$@"; do
  if [[ "$ARG" == "--apply" ]]; then APPLY=true; fi
done
if [[ "$APPLY" == false ]]; then
  "${GAP_TOOLS_PYTHON_BIN:-python3}" -I -B "$ROOT/scripts/documentation_server/lifecycle.py" install "$@"
  printf '%s\n' 'Nur Plan, NICHT installiert: --source-commit SHA und --apply erforderlich.' >&2
  exit 2
fi
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -I -B "$ROOT/scripts/documentation_server/lifecycle.py" install "$@"
