#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PERSONA_ID="${1:-new_persona}"
PERSONA_NAME="${2:-Neue Persona}"
PERSONA_TYPE="${3:-fictional}"

PERSONA_FILE="$ROOT_DIR/personas/${PERSONA_ID}.json"
MEMORY_DIR="$ROOT_DIR/memory/personas/${PERSONA_ID}"

if [ -f "$PERSONA_FILE" ]; then
  echo "Fehler: Persona existiert bereits: $PERSONA_FILE" >&2
  exit 1
fi

mkdir -p "$MEMORY_DIR/daily" "$MEMORY_DIR/projects"

cat > "$PERSONA_FILE" <<EOF
{
  "id": "$PERSONA_ID",
  "name": "$PERSONA_NAME",
  "type": "$PERSONA_TYPE",
  "languages": ["German"],
  "personality": {
    "tone": "natural",
    "intelligence": "adaptive",
    "humor": "light",
    "emotional_style": "balanced"
  },
  "modes": ["social_chat"],
  "memory": {
    "long_term": "memory/personas/${PERSONA_ID}/MEMORY.md",
    "daily": "memory/personas/${PERSONA_ID}/daily/",
    "projects": "memory/personas/${PERSONA_ID}/projects/",
    "dreams": "memory/personas/${PERSONA_ID}/DREAMS.md"
  },
  "disclosure": {
    "persona_disclosure_required": true,
    "public_use_requires_ai_disclosure": true
  }
}
EOF

cat > "$MEMORY_DIR/MEMORY.md" <<EOF
# ${PERSONA_NAME} Memory

- Erste Erinnerungen folgen hier.
EOF

cat > "$MEMORY_DIR/DREAMS.md" <<'EOF'
# Dreams

- Zusammenfassungen und Verdichtungen.
EOF

echo "Persona erstellt: $PERSONA_FILE"
