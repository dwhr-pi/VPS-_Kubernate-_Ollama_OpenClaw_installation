#!/bin/bash
# ==============================================================================
# LANGFLOW_INSTALL.SH - Installation von LangFlow
# LangFlow ist ein UI für LangChain, um LLM-Anwendungen visuell zu erstellen.
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
init_tool_tracking "LangFlow"

LANGFLOW_DIR="/opt/langflow"

echo -e "${BLUE}Starte Installation von LangFlow...${NC}"

# 1. LangFlow aus GitHub klonen
if [ -d "$LANGFLOW_DIR" ]; then
    echo -e "${YELLOW}LangFlow Verzeichnis $LANGFLOW_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$LANGFLOW_DIR"
    git pull
else
    echo -e "${BLUE}Klone LangFlow in $LANGFLOW_DIR...${NC}"
    sudo mkdir -p "$LANGFLOW_DIR"
    sudo chown -R $USER:$USER "$LANGFLOW_DIR"
    git clone https://github.com/logspace-ai/langflow.git "$LANGFLOW_DIR"
    cd "$LANGFLOW_DIR"
fi

# 2. Python-Abhängigkeiten installieren
echo -e "${BLUE}Installiere Python-Abhängigkeiten für LangFlow...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

# 3. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: LangFlow Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet LangFlow auf Port 7860.${NC}"

echo -e "${GREEN}LangFlow Installation abgeschlossen.${NC}"
mark_current_tool_installed
