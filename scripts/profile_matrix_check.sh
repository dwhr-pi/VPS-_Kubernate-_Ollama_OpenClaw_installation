#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Profile-Matrix-Check"

for file in "$ROOT_DIR/docs/PROFILE_INDEX.md" "$ROOT_DIR/docs/PROFILE_TOOL_MAPPING.md" "$ROOT_DIR/docs/Profile/Next_Level_Profile_Backlog.md"; do
  if [ -f "$file" ]; then
    echo "OK: ${file#$ROOT_DIR/}"
  else
    echo "FEHLT: ${file#$ROOT_DIR/}"
    exit 1
  fi
done

if [ -f "$ROOT_DIR/scripts/check_profile_registry_sync.sh" ]; then
  bash "$ROOT_DIR/scripts/check_profile_registry_sync.sh" || true
fi
