#!/bin/bash
#
# Skript: Texter_Werbung_Marketing_install.sh
# Beschreibung: Dieses Skript installiert Tools und Konfigurationen, die speziell für Texter, Werbefachleute und Marketingexperten nützlich sind.
# Es umfasst Content-Generierungs-Tools, SEO-Analyse-Tools, Social Media Management und KI-gestützte Marketing-Plattformen.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Texter, Werbung & Marketing Profil ausgewählt wird.
#

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
init_profile_tracking "Texter_Werbung_Marketing"

echo -e "${BLUE}Starte Installation des Texter, Werbung & Marketing Profils...${NC}"

# Beispiel: Installation von n8n (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/n8n_install.sh" ]; then
    echo -e "${BLUE}Installiere n8n als Teil des Texter, Werbung & Marketing Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/n8n_install.sh"
else
    echo -e "${YELLOW}n8n Installationsskript nicht gefunden. Überspringe n8n Installation.${NC}"
fi

# Beispiel: Installation von Activepieces (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/activepieces_install.sh" ]; then
    echo -e "${BLUE}Installiere Activepieces als Teil des Texter, Werbung & Marketing Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/activepieces_install.sh"
else
    echo -e "${YELLOW}Activepieces Installationsskript nicht gefunden. Überspringe Activepieces Installation.${NC}"
fi

for tool_script in langchain_install.sh chromadb_install.sh playwright_install.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Installiere ${tool_script%.sh} als Teil des Texter, Werbung & Marketing Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Texter, Werbung & Marketing Profil Installation abgeschlossen.${NC}"
mark_current_profile_installed

