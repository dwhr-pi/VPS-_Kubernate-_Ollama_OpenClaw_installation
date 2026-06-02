#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"
REPORT_PATH=""

if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: bash tools/websitefactory/scripts/check-build.sh <generated-project-dir>" >&2
  exit 2
fi

if [[ ! -f "$TARGET_DIR/package.json" ]]; then
  echo "Fehler: package.json nicht gefunden: $TARGET_DIR" >&2
  exit 1
fi

REPORT_PATH="$TARGET_DIR/docs/build-report.md"
mkdir -p "$(dirname "$REPORT_PATH")"

{
  echo "# Build Report"
  echo
  echo "## Zeit"
  echo
  date -u +"%Y-%m-%dT%H:%M:%SZ"
  echo
  echo "## Schritte"
  echo
  echo "- pnpm install"
  echo "- pnpm build"
  echo "- Preview manuell via run-preview.sh"
  echo "- Screenshot optional via screenshot.sh"
  echo
} > "$REPORT_PATH"

cd "$TARGET_DIR"
pnpm install
pnpm build

{
  echo "## Ergebnis"
  echo
  echo "- Build: erfolgreich"
  echo "- Auto-Fix-Runden: 0/3 in diesem Lauf"
  echo
} >> "$REPORT_PATH"

echo "Build-Check erfolgreich. Report: $REPORT_PATH"
