#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Tool-Registry-Check"

for file in "$ROOT_DIR/config/tools.yml" "$ROOT_DIR/docs/TOOL_INDEX.md" "$ROOT_DIR/docs/TOOL_DEPLOYMENT_MATRIX.md"; do
  if [ -f "$file" ]; then
    echo "OK: ${file#$ROOT_DIR/}"
  else
    echo "FEHLT: ${file#$ROOT_DIR/}"
    exit 1
  fi
done

if [ -f "$ROOT_DIR/scripts/check_tools.sh" ]; then
  bash "$ROOT_DIR/scripts/check_tools.sh" || true
fi

if [ -f "$ROOT_DIR/scripts/check_tool_lifecycle.sh" ]; then
  bash "$ROOT_DIR/scripts/check_tool_lifecycle.sh" || true
fi
