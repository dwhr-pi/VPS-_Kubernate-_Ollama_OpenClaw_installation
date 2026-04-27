#!/bin/bash
# ==============================================================================
# OLLAMA_INSTALL.SH - Installation von Ollama
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Ollama"

echo -e "${BLUE}Starte Installation von Ollama...${NC}"

if command -v ollama >/dev/null 2>&1; then
    echo -e "${GREEN}Ollama ist bereits installiert.${NC}"
    exit 0
fi

curl -fsSL https://ollama.com/install.sh | sh
if ! command -v ollama >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Ollama konnte nicht installiert werden.${NC}"
    exit 1
fi

echo -e "${GREEN}Ollama Installation abgeschlossen.${NC}"
mark_current_tool_installed

