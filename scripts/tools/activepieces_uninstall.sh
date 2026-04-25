#!/bin/bash
# ==============================================================================
# ACTIVEPIECES_UNINSTALL.SH - Deinstallation von Activepieces
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

ACTIVEPIECES_DIR="/opt/activepieces"

echo -e "${BLUE}Starte Deinstallation von Activepieces...${NC}"

if [ -d "$ACTIVEPIECES_DIR" ]; then
    echo -e "${YELLOW}Lösche Activepieces Verzeichnis $ACTIVEPIECES_DIR...${NC}"
    sudo rm -rf "$ACTIVEPIECES_DIR"
    echo -e "${GREEN}Activepieces erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Activepieces ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}Activepieces Deinstallation abgeschlossen.${NC}"
