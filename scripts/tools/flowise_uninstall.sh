#!/bin/bash
# ==============================================================================
# FLOWISE_UNINSTALL.SH - Deinstallation von Flowise
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
init_tool_tracking "Flowise"

FLOWISE_DIR="/opt/flowise"

echo -e "${BLUE}Starte Deinstallation von Flowise...${NC}"

if [ -d "$FLOWISE_DIR" ]; then
    echo -e "${YELLOW}Lösche Flowise Verzeichnis $FLOWISE_DIR...${NC}"
    sudo rm -rf "$FLOWISE_DIR"
    echo -e "${GREEN}Flowise erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Flowise ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}Flowise Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed
