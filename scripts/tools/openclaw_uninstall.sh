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
