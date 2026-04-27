#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SKILL_NAME="${2:-generic}"
TARGET_DIR="/opt/openclaw/config/skills"

echo -e "${BLUE}Konfiguriere OpenClaw-Skillprofil: ${SKILL_NAME}${NC}"
sudo mkdir -p "$TARGET_DIR"
sudo tee "${TARGET_DIR}/${SKILL_NAME}.json" >/dev/null <<EOF
{
  "skill": "${SKILL_NAME}",
  "ollama_host": "http://localhost:11434",
  "default_model": "llama3.2:1b",
  "openclaw_profile_hint": "${SKILL_NAME}",
  "created_by": "openclaw_skill_config.sh"
}
EOF
echo -e "${GREEN}Skill-Konfiguration wurde unter ${TARGET_DIR}/${SKILL_NAME}.json angelegt.${NC}"
