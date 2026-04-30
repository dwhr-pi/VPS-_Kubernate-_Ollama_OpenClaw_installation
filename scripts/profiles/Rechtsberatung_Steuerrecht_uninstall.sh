#!/bin/bash
#
# Skript: Rechtsberatung_Steuerrecht_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum Profil 'Rechtsberatung & Steuerrecht' gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Profil 'Rechtsberatung & Steuerrecht' deinstalliert wird.
#

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
init_profile_tracking "Rechtsberatung_Steuerrecht"

echo -e "${BLUE}Starte Deinstallation des Profils 'Rechtsberatung & Steuerrecht'...${NC}"

# 1. Deinstallation von Web-Search & Fetch Tools (Beispiel: pup, jq, wget, curl)
echo -e "${BLUE}Deinstalliere Web-Search & Fetch Tools (pup, jq, wget, curl)...${NC}"
sudo apt-get remove -y pup jq wget curl
sudo apt-get autoremove -y

# 2. Deinstallation von PDF-Reader / Document-Parser (Beispiel: poppler-utils, tesseract-ocr)
echo -e "${BLUE}Deinstalliere PDF-Reader / Document-Parser (poppler-utils, tesseract-ocr)...${NC}"
sudo apt-get remove -y poppler-utils tesseract-ocr
sudo apt-get autoremove -y

# 3. Deinstallation von Zotero
if [ -f "$INSTALL_DIR/scripts/tools/zotero_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Zotero als Teil des Profils 'Rechtsberatung & Steuerrecht'...${NC}"
    bash "$INSTALL_DIR/scripts/tools/zotero_uninstall.sh"
else
    echo -e "${YELLOW}Zotero Deinstallationsskript nicht gefunden. Überspringe Zotero Deinstallation.${NC}"
fi

# 4. Entfernen von OpenClaw Skills Konfigurationen (falls spezifische Skills für Rechtsdatenbanken existieren)
echo -e "${BLUE}Entferne OpenClaw Konfigurationen für juristische Skills...${NC}"
# Hier könnten Skripte aufgerufen werden, die OpenClaw-Skills für juristische Datenbanken dekonfigurieren.

for tool_script in risk_scoring_uninstall.sh deadline_checker_uninstall.sh tax_calculator_uninstall.sh neo4j_uninstall.sh pdf_parser_uninstall.sh drafting_agent_uninstall.sh risk_agent_uninstall.sh tax_law_agent_uninstall.sh lawfirm_uninstall.sh ai_powered_law_firms_uninstall.sh eullm_uninstall.sh qdrant_uninstall.sh chromadb_uninstall.sh llamaindex_uninstall.sh langchain_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des Profils 'Rechtsberatung & Steuerrecht'...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Profil 'Rechtsberatung & Steuerrecht' Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
