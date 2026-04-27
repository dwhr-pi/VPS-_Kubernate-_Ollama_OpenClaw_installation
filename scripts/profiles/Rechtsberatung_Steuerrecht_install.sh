#!/bin/bash
#
# Skript: Rechtsberatung_Steuerrecht_install.sh
# Beschreibung: Dieses Skript installiert Tools und Konfigurationen, die speziell für die Rechtsberatung und das Steuerrecht nützlich sind.
# Es umfasst Web-Search & Fetch für juristische Datenbanken, PDF-Reader/Document-Parser für die Analyse von Rechtsdokumenten und Zotero für die Literaturverwaltung.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Profil 'Rechtsberatung & Steuerrecht' ausgewählt wird.
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
init_profile_tracking "Rechtsberatung_Steuerrecht"

echo -e "${BLUE}Starte Installation des Profils 'Rechtsberatung & Steuerrecht'...${NC}"

# 1. Installation von Web-Search & Fetch Tools (pup, jq, wget, curl)
echo -e "${BLUE}Installiere Web-Search & Fetch Tools (pup, jq, wget, curl)...${NC}"
sudo apt-get update
sudo apt-get install -y pup jq wget curl

# 2. Installation von PDF-Reader / Document-Parser (poppler-utils, tesseract-ocr)
echo -e "${BLUE}Installiere PDF-Reader / Document-Parser (poppler-utils, tesseract-ocr)...${NC}"
sudo apt-get install -y poppler-utils tesseract-ocr

# 3. Installation von Zotero
if [ -f "$INSTALL_DIR/scripts/tools/zotero_install.sh" ]; then
    echo -e "${BLUE}Installiere Zotero als Teil des Profils 'Rechtsberatung & Steuerrecht'...${NC}"
    bash "$INSTALL_DIR/scripts/tools/zotero_install.sh"
else
    echo -e "${YELLOW}Zotero Installationsskript nicht gefunden. Überspringe Zotero Installation.${NC}"
fi

# 4. Konfiguration für OpenClaw Skills (falls spezifische Skills für Rechtsdatenbanken existieren)
echo -e "${BLUE}Konfiguriere OpenClaw für juristische Skills...${NC}"
# Hier könnten Skripte aufgerufen werden, die OpenClaw-Skills für juristische Datenbanken konfigurieren.
# Beispiel: $INSTALL_DIR/scripts/openclaw_skill_config.sh --skill legal_db_search

for tool_script in langchain_install.sh llamaindex_install.sh chromadb_install.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Installiere ${tool_script%.sh} als Teil des Profils 'Rechtsberatung & Steuerrecht'...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Profil 'Rechtsberatung & Steuerrecht' Installation abgeschlossen.${NC}"
mark_current_profile_installed

