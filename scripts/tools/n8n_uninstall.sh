#!/bin/bash
# ==============================================================================
# N8N_UNINSTALL.SH - Deinstallation von n8n
# ==============================================================================

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "n8n"

N8N_DIR="/opt/n8n"

echo -e "${BLUE}Starte Deinstallation von n8n...${NC}"

if [ -d "$N8N_DIR" ]; then
    echo -e "${YELLOW}Lösche n8n Verzeichnis $N8N_DIR...${NC}"
    sudo rm -rf "$N8N_DIR"
    echo -e "${GREEN}n8n erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}n8n ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}n8n Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed
