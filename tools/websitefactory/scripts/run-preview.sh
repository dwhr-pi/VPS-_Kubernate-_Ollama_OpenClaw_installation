#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"
PORT="${PORT:-4321}"

if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: bash tools/websitefactory/scripts/run-preview.sh <generated-project-dir>" >&2
  exit 2
fi

if [[ ! -f "$TARGET_DIR/package.json" ]]; then
  echo "Fehler: package.json nicht gefunden: $TARGET_DIR" >&2
  exit 1
fi

cd "$TARGET_DIR"
pnpm dev --host 127.0.0.1 --port "$PORT"
