#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Ultimate KI Setup wrapper"
echo "Repo: $ROOT_DIR"

if [ -f "$ROOT_DIR/scripts/preflight.sh" ]; then
  bash "$ROOT_DIR/scripts/preflight.sh" || true
fi

echo "Starte bestehendes Hauptsetup. Fuer interaktiv: bash setup_ultimate.sh"
bash "$ROOT_DIR/setup_ultimate.sh" "$@"
