#!/bin/bash
# ==============================================================================
# CLAWHUB_CLI_UNINSTALL.SH - Deinstallation von Clawhub CLI
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

CLAWHUB_CLI_DIR="/opt/clawhub-cli"

echo -e "${BLUE}Starte Deinstallation von Clawhub CLI...${NC}"

if [ -d "$CLAWHUB_CLI_DIR" ]; then
    echo -e "${YELLOW}Lösche Clawhub CLI Verzeichnis $CLAWHUB_CLI_DIR...${NC}"
    sudo rm -rf "$CLAWHUB_CLI_DIR"
    echo -e "${GREEN}Clawhub CLI erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Clawhub CLI ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

# Symbolische Verknüpfung entfernen
if [ -L /usr/local/bin/clawhub ]; then
    echo -e "${YELLOW}Entferne symbolische Verknüpfung /usr/local/bin/clawhub...${NC}"
    sudo rm /usr/local/bin/clawhub
fi

echo -e "${GREEN}Clawhub CLI Deinstallation abgeschlossen.${NC}"
