#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for persona_id in anna_support lena_social_chat max_callcenter cyra_cyborg_ai robo_pet_companion; do
  test -f "$ROOT_DIR/memory/personas/$persona_id/MEMORY.md"
  test -d "$ROOT_DIR/memory/personas/$persona_id/daily"
  test -d "$ROOT_DIR/memory/personas/$persona_id/projects"
done

echo "Memory-Dateien und Verzeichnisse vorhanden."
