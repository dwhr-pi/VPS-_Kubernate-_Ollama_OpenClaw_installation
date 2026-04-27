#!/bin/bash
# ==============================================================================
# OLLAMA_UNINSTALL.SH - Deinstallation von Ollama
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

echo -e "${BLUE}Starte Deinstallation von Ollama...${NC}"

sudo systemctl stop ollama >/dev/null 2>&1 || true
sudo systemctl disable ollama >/dev/null 2>&1 || true
sudo rm -f /usr/local/bin/ollama
sudo rm -f /etc/systemd/system/ollama.service
sudo systemctl daemon-reload >/dev/null 2>&1 || true
sudo rm -rf /usr/share/ollama /var/lib/ollama

if command -v ollama >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Ollama scheint noch installiert zu sein.${NC}"
    exit 1
fi

echo -e "${GREEN}Ollama Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed

