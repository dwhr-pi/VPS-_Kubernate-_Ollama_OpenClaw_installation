#!/bin/bash
# ==============================================================================
# OPENMANUS_UNINSTALL.SH - Deinstallation von OpenManus
# ==============================================================================

GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

OPENMANUS_DIR="/opt/openmanus"

echo -e "${BLUE}Starte Deinstallation von OpenManus...${NC}"

if [ -d "$OPENMANUS_DIR" ]; then
    echo -e "${YELLOW}Lösche OpenManus Verzeichnis $OPENMANUS_DIR...${NC}"
    sudo rm -rf "$OPENMANUS_DIR"
    echo -e "${GREEN}OpenManus erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}OpenManus ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}OpenManus Deinstallation abgeschlossen.${NC}"
