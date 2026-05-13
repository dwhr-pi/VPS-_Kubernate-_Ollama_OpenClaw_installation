#!/bin/bash
# ==============================================================================
# AUTO_UPDATE.SH - System- und pnpm-Update
# Dieses Skript aktualisiert das Betriebssystem und stellt sicher, dass pnpm
# auf der neuesten Version ist. Zusaetzlich wird das Setup-Repository
# aktualisiert, falls das Skript innerhalb eines Git-Klons laeuft.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${BLUE}Starte Setup-, System- und pnpm-Update...${NC}"

# 1. Setup-Repository aktualisieren
echo -e "${GREEN}1/3: Aktualisiere das Setup-Repository...${NC}"
if [ -x "$INSTALL_DIR/scripts/update_setup_only.sh" ]; then
    "$INSTALL_DIR/scripts/update_setup_only.sh"
else
    bash "$INSTALL_DIR/scripts/update_setup_only.sh"
fi

# 2. System aktualisieren
echo -e "${GREEN}2/3: Führe System-Updates durch...${NC}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get autoremove -y

# 3. pnpm aktualisieren
echo -e "${GREEN}3/3: Aktualisiere pnpm...${NC}"
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

echo -e "${GREEN}Setup-, System- und pnpm-Update abgeschlossen.${NC}"
echo -e "${YELLOW}Falls sich das Setup selbst geaendert hat, starten Sie das Menue danach neu.${NC}"
