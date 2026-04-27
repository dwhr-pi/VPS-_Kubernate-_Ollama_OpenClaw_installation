#!/bin/bash
# ==============================================================================
# CLAWBAKE_UNINSTALL.SH - Deinstallation von Clawbake
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
init_tool_tracking "Clawbake"

CLAWBAKE_DIR="/opt/clawbake"

echo -e "${BLUE}Starte Deinstallation von Clawbake...${NC}"

if [ -d "$CLAWBAKE_DIR" ]; then
    echo -e "${YELLOW}Lösche Clawbake Verzeichnis $CLAWBAKE_DIR...${NC}"
    sudo rm -rf "$CLAWBAKE_DIR"
    echo -e "${GREEN}Clawbake erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Clawbake ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}Clawbake Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed

