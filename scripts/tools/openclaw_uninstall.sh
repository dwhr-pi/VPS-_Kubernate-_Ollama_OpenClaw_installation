#!/bin/bash
# ==============================================================================
# OPENCLAW_UNINSTALL.SH - Deinstallation von OpenClaw
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
init_tool_tracking "OpenClaw"

OPENCLAW_DIR="/opt/openclaw"

echo -e "${BLUE}Starte Deinstallation von OpenClaw...${NC}"

if [ -d "$OPENCLAW_DIR" ]; then
    echo -e "${YELLOW}Lösche OpenClaw Verzeichnis $OPENCLAW_DIR...${NC}"
    sudo rm -rf "$OPENCLAW_DIR"
    echo -e "${GREEN}OpenClaw erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}OpenClaw ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}OpenClaw Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed

