#!/bin/bash
# ==============================================================================
# OPENMANUS_INSTALL.SH - Installation von OpenManus
# ==============================================================================

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/lib/common.sh"
init_tool_tracking "OpenManus"

OPENMANUS_DIR="/opt/openmanus"
OPENMANUS_REPO_URL="$(get_custom_repo_url "OPENMANUS" "https://github.com/openmanus/openmanus.git")"

echo -e "${BLUE}Starte Installation von OpenManus...${NC}"

# 1. OpenManus aus GitHub klonen
if [ -d "$OPENMANUS_DIR" ]; then
    echo -e "${YELLOW}OpenManus Verzeichnis $OPENMANUS_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$OPENMANUS_DIR"
    git pull
else
    echo -e "${BLUE}Klone OpenManus in $OPENMANUS_DIR...${NC}"
    sudo mkdir -p "$OPENMANUS_DIR"
    sudo chown -R $USER:$USER "$OPENMANUS_DIR"
    git clone "$OPENMANUS_REPO_URL" "$OPENMANUS_DIR"
    cd "$OPENMANUS_DIR"
fi

# 2. Python-Abhängigkeiten installieren
echo -e "${BLUE}Installiere Python-Abhängigkeiten für OpenManus...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

# 3. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: OpenManus Konfiguration muss eventuell manuell angepasst werden.${NC}"

echo -e "${GREEN}OpenManus Installation abgeschlossen.${NC}"
mark_current_tool_installed
