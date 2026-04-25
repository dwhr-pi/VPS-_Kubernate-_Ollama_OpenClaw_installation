#!/bin/bash
# ==============================================================================
# OPENCLAW_UNINSTALL.SH - Deinstallation von OpenClaw
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

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
