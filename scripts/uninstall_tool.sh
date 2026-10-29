#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_ID="${1:-}"

if [[ -z "$TOOL_ID" || "$TOOL_ID" == "--help" ]]; then
  echo "Nutzung: bash scripts/uninstall_tool.sh <tool_id> [--dry-run]"
  exit 0
fi

DRY_RUN=0
if [[ $# -gt 2 || ( $# -eq 2 && "$2" != "--dry-run" ) ]]; then
  echo "Fehler: Nur <tool_id> und optional --dry-run erlaubt." >&2
  exit 2
fi
if [[ "${2:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

SCRIPT="$(python3 -I -B "$ROOT_DIR/scripts/lib/tool_dispatch.py" "$TOOL_ID" --action uninstall)" || exit 1

if [[ ! -f "$SCRIPT" ]]; then
  echo "WARN: Kein Uninstaller gefunden: $SCRIPT"
  echo "Keine Aenderung vorgenommen."
  exit 1
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry-run: wuerde ausfuehren: $SCRIPT"
  exit 0
fi

bash "$SCRIPT"

