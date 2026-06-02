#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:4321}"
OUTPUT_PATH="${2:-./jobs/screenshots/preview.png}"

mkdir -p "$(dirname "$OUTPUT_PATH")"

if pnpm exec playwright --version >/dev/null 2>&1; then
  pnpm exec playwright screenshot "$URL" "$OUTPUT_PATH"
  echo "Screenshot erstellt: $OUTPUT_PATH"
  exit 0
fi

echo "Playwright ist im Zielprojekt noch nicht installiert."
echo "Screenshot-Schritt wurde bewusst uebersprungen: $OUTPUT_PATH"
