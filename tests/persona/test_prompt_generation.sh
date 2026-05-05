#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for file in \
  "$ROOT_DIR/prompts/persona/persona_base.md" \
  "$ROOT_DIR/prompts/persona/persona_modes.md" \
  "$ROOT_DIR/prompts/persona/persona_memory_injection.md" \
  "$ROOT_DIR/prompts/persona/persona_response_style.md" \
  "$ROOT_DIR/prompts/persona/persona_multimodal.md"; do
  test -f "$file"
done

echo "Prompt-Bausteine vorhanden."
