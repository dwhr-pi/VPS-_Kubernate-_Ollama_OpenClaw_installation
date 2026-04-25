#!/bin/bash
# ==============================================================================
# CLAWHUB_CLI_INSTALL.SH - Installation von Clawhub CLI
# Clawhub CLI ist ein Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten.
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

CLAWHUB_CLI_DIR="/opt/clawhub-cli"

echo -e "${BLUE}Starte Installation von Clawhub CLI...${NC}"

# 1. Clawhub CLI aus GitHub klonen
if [ -d "$CLAWHUB_CLI_DIR" ]; then
    echo -e "${YELLOW}Clawhub CLI Verzeichnis $CLAWHUB_CLI_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$CLAWHUB_CLI_DIR"
    git pull
else
    echo -e "${BLUE}Klone Clawhub CLI in $CLAWHUB_CLI_DIR...${NC}"
    sudo mkdir -p "$CLAWHUB_CLI_DIR"
    sudo chown -R $USER:$USER "$CLAWHUB_CLI_DIR"
    git clone https://github.com/openclaw/clawhub-cli.git "$CLAWHUB_CLI_DIR"
    cd "$CLAWHUB_CLI_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Clawhub CLI mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Clawhub CLI fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Clawhub CLI bauen
echo -e "${BLUE}Baue Clawhub CLI mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Clawhub CLI fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Verknüpfung erstellen (optional)
echo -e "${BLUE}Erstelle symbolische Verknüpfung für einfachen Zugriff...${NC}"
sudo ln -sf "$CLAWHUB_CLI_DIR/bin/run" /usr/local/bin/clawhub

echo -e "${GREEN}Clawhub CLI Installation abgeschlossen. Du kannst es jetzt mit 'clawhub' aufrufen.${NC}"
