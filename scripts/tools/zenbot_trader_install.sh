#!/bin/bash
# ==============================================================================
# ZENBOT_TRADER_INSTALL.SH - Installation von Zenbot-trader
# Zenbot-trader ist eine Plattform für automatisierten Krypto-Handel.
# ==============================================================================

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Zenbot_trader"

ZENBOT_DIR="/opt/zenbot-trader"

echo -e "${BLUE}Starte Installation von Zenbot-trader...${NC}"

# 1. Zenbot-trader aus GitHub klonen
if [ -d "$ZENBOT_DIR" ]; then
    echo -e "${YELLOW}Zenbot-trader Verzeichnis $ZENBOT_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$ZENBOT_DIR"
    git pull
else
    echo -e "${BLUE}Klone Zenbot-trader in $ZENBOT_DIR...${NC}"
    sudo mkdir -p "$ZENBOT_DIR"
    sudo chown -R $USER:$USER "$ZENBOT_DIR"
    git clone https://github.com/dwhr-pi/zenbot-trader-platform.git "$ZENBOT_DIR"
    cd "$ZENBOT_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Zenbot-trader mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Zenbot-trader fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Zenbot-trader bauen (falls notwendig)
echo -e "${BLUE}Baue Zenbot-trader mit pnpm (falls notwendig)...${NC}"
pnpm build # Annahme: Es gibt einen Build-Schritt
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Hinweis: pnpm build für Zenbot-trader fehlgeschlagen oder nicht notwendig.${NC}"
fi

# 4. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: Zenbot-trader Konfiguration (z.B. API-Keys für Börsen) muss manuell angepasst werden.${NC}"

echo -e "${GREEN}Zenbot-trader Installation abgeschlossen.${NC}"
mark_current_tool_installed
