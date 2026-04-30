#!/bin/bash
# ==============================================================================
# KIMI2_UNINSTALL.SH - Deinstalliert Kimi 2 (Moonshot AI)
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
init_tool_tracking "Kimi2"

KIMI2_DIR="/opt/kimi2"

echo -e "${BLUE}Starte Deinstallation von Kimi 2...${NC}"

# Prüfen, ob Kimi 2 installiert ist
if [ ! -d "$KIMI2_DIR" ]; then
    echo -e "${YELLOW}Kimi 2 ist nicht installiert unter ${KIMI2_DIR}. Überspringe Deinstallation.${NC}"
    exit 0
fi

# Installationsverzeichnis entfernen
echo -e "${BLUE}Entferne Kimi 2 Installationsverzeichnis: ${KIMI2_DIR}${NC}"
sudo rm -rf "$KIMI2_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler beim Entfernen des Kimi 2 Installationsverzeichnisses.${NC}"
    exit 1
fi

echo -e "${GREEN}Kimi 2 erfolgreich deinstalliert.${NC}"
mark_current_tool_removed
