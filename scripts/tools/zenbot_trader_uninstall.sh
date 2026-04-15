#!/bin/bash
# ==============================================================================
# ZENBOT_TRADER_UNINSTALL.SH - Deinstallation von Zenbot-trader
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

ZENBOT_DIR="/opt/zenbot-trader"

echo -e "${BLUE}Starte Deinstallation von Zenbot-trader...${NC}"

if [ -d "$ZENBOT_DIR" ]; then
    echo -e "${YELLOW}Lösche Zenbot-trader Verzeichnis $ZENBOT_DIR...${NC}"
    sudo rm -rf "$ZENBOT_DIR"
    echo -e "${GREEN}Zenbot-trader erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Zenbot-trader ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}Zenbot-trader Deinstallation abgeschlossen.${NC}"
