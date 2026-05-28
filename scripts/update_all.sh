#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/scripts/operations/update_all_tools.sh" ]; then
  exec bash "$ROOT_DIR/scripts/operations/update_all_tools.sh" "$@"
fi
echo "Update-Wrapper: kein update_all_tools.sh gefunden."
