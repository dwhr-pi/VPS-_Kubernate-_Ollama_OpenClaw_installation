#!/bin/bash
# ==============================================================================
# ACTIVEPIECES_INSTALL.SH - Installation von Activepieces
# Activepieces ist eine Open-Source-Alternative zu Zapier für Workflow-Automatisierung.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Activepieces"

ACTIVEPIECES_DIR="/opt/activepieces"

echo -e "${BLUE}Starte Installation von Activepieces...${NC}"

# 1. Activepieces aus GitHub klonen
if [ -d "$ACTIVEPIECES_DIR" ]; then
    echo -e "${YELLOW}Activepieces Verzeichnis $ACTIVEPIECES_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$ACTIVEPIECES_DIR"
    git pull
else
    echo -e "${BLUE}Klone Activepieces in $ACTIVEPIECES_DIR...${NC}"
    sudo mkdir -p "$ACTIVEPIECES_DIR"
    sudo chown -R $USER:$USER "$ACTIVEPIECES_DIR"
    git clone https://github.com/activepieces/activepieces.git "$ACTIVEPIECES_DIR"
    cd "$ACTIVEPIECES_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Activepieces mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Activepieces fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Activepieces bauen
echo -e "${BLUE}Baue Activepieces mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Activepieces fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: Activepieces Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet Activepieces auf Port 3000.${NC}"

echo -e "${GREEN}Activepieces Installation abgeschlossen.${NC}"
mark_current_tool_installed

