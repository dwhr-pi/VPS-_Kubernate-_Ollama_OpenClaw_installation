#!/usr/bin/env bash
# Remove only the private hash-verified application, not user data or history.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
APPLY=false
for ARG in "$@"; do
  if [[ "$ARG" == "--apply" ]]; then APPLY=true; fi
done
if [[ "$APPLY" == false ]]; then
  "${GAP_TOOLS_PYTHON_BIN:-python3}" -I -B "$ROOT/scripts/documentation_server/lifecycle.py" uninstall "$@"
  printf '%s\n' 'Nur Plan, NICHT deinstalliert: --apply erforderlich.' >&2
  exit 2
fi
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -I -B "$ROOT/scripts/documentation_server/lifecycle.py" uninstall "$@"
