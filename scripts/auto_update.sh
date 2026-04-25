#!/bin/bash
# ==============================================================================
# AUTO_UPDATE.SH - System- und pnpm-Update
# Dieses Skript aktualisiert das Betriebssystem und stellt sicher, dass pnpm
# auf der neuesten Version ist.
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

echo -e "${BLUE}Starte System- und pnpm-Update...${NC}"

# 1. System aktualisieren
echo -e "${GREEN}1/2: Führe System-Updates durch...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# 2. pnpm aktualisieren
echo -e "${GREEN}2/2: Aktualisiere pnpm...${NC}"
if command -v pnpm >/dev/null 2>&1; then
    sudo pnpm add -g pnpm@latest
    echo -e "${GREEN}pnpm auf die neueste Version aktualisiert.${NC}"
else
    echo -e "${YELLOW}pnpm ist nicht installiert. Installiere pnpm...${NC}"
    sudo npm install -g pnpm
    if ! command -v pnpm >/dev/null 2>&1; then
        echo -e "${RED}Fehler: pnpm konnte nicht installiert werden. Bitte manuell prüfen.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}System- und pnpm-Update abgeschlossen.${NC}"
