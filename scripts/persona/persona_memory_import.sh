#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PERSONA_ID="${1:-}"
IMPORT_FILE="${2:-}"

if [ -z "$PERSONA_ID" ] || [ -z "$IMPORT_FILE" ]; then
  echo "Nutzung: bash scripts/persona/persona_memory_import.sh <persona_id> <datei>" >&2
  exit 1
fi

TARGET_MEMORY="$ROOT_DIR/memory/personas/$PERSONA_ID/MEMORY.md"

if [ ! -f "$IMPORT_FILE" ]; then
  echo "Fehler: Importdatei nicht gefunden: $IMPORT_FILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET_MEMORY")"
touch "$TARGET_MEMORY"

{
  echo
  echo "## Import $(date -Iseconds)"
  cat "$IMPORT_FILE"
} >> "$TARGET_MEMORY"

echo "Memory importiert nach: $TARGET_MEMORY"
