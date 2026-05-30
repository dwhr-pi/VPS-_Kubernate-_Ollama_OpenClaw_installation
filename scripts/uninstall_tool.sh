#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_ID="${1:-}"

if [[ -z "$TOOL_ID" || "$TOOL_ID" == "--help" ]]; then
  echo "Nutzung: bash scripts/uninstall_tool.sh <tool_id> [--dry-run]"
  exit 0
fi

DRY_RUN=0
if [[ "${2:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

SCRIPT="$ROOT_DIR/scripts/tools/${TOOL_ID}_uninstall.sh"

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

