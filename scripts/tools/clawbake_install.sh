#!/bin/bash
# ==============================================================================
# CLAWBAKE_INSTALL.SH - Installation von Clawbake
# Clawbake ist ein Tool zur Automatisierung von Builds und Deployments.
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

CLAWBAKE_DIR="/opt/clawbake"

echo -e "${BLUE}Starte Installation von Clawbake...${NC}"

# 1. Clawbake aus GitHub klonen
if [ -d "$CLAWBAKE_DIR" ]; then
    echo -e "${YELLOW}Clawbake Verzeichnis $CLAWBAKE_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$CLAWBAKE_DIR"
    git pull
else
    echo -e "${BLUE}Klone Clawbake in $CLAWBAKE_DIR...${NC}"
    sudo mkdir -p "$CLAWBAKE_DIR"
    sudo chown -R $USER:$USER "$CLAWBAKE_DIR"
    git clone https://github.com/openclaw/clawbake.git "$CLAWBAKE_DIR"
    cd "$CLAWBAKE_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Clawbake mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Clawbake fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Clawbake bauen
echo -e "${BLUE}Baue Clawbake mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Clawbake fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: Clawbake Konfiguration muss eventuell manuell angepasst werden.${NC}"

echo -e "${GREEN}Clawbake Installation abgeschlossen.${NC}"
