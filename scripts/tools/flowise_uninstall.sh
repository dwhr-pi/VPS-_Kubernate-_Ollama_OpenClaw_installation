#!/bin/bash
# ==============================================================================
# FLOWISE_UNINSTALL.SH - Deinstallation von Flowise
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

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
