#!/bin/bash
# ==============================================================================
# FLOWISE_INSTALL.SH - Installation von Flowise
# Flowise ist ein Open-Source-UI für LLM-Anwendungen, basierend auf LangchainJS.
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
init_tool_tracking "Flowise"

FLOWISE_DIR="/opt/flowise"

echo -e "${BLUE}Starte Installation von Flowise...${NC}"

# 1. Flowise aus GitHub klonen
if [ -d "$FLOWISE_DIR" ]; then
    echo -e "${YELLOW}Flowise Verzeichnis $FLOWISE_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$FLOWISE_DIR"
    git pull
else
    echo -e "${BLUE}Klone Flowise in $FLOWISE_DIR...${NC}"
    sudo mkdir -p "$FLOWISE_DIR"
    sudo chown -R $USER:$USER "$FLOWISE_DIR"
    git clone https://github.com/FlowiseAI/FlowiseChatbot.git "$FLOWISE_DIR"
    cd "$FLOWISE_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Flowise mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Flowise fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Flowise bauen
echo -e "${BLUE}Baue Flowise mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Flowise fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: Flowise Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet Flowise auf Port 3000.${NC}"

echo -e "${GREEN}Flowise Installation abgeschlossen.${NC}"
mark_current_tool_installed
