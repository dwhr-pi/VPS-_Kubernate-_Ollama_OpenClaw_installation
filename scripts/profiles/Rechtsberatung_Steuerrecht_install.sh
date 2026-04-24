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

echo -e "${BLUE}Starte Installation des Profils 'Rechtsberatung & Steuerrecht'...${NC}"

# 1. Installation von Web-Search & Fetch Tools (pup, jq, wget, curl)
echo -e "${BLUE}Installiere Web-Search & Fetch Tools (pup, jq, wget, curl)...${NC}"
sudo apt-get update
sudo apt-get install -y pup jq wget curl

# 2. Installation von PDF-Reader / Document-Parser (poppler-utils, tesseract-ocr)
echo -e "${BLUE}Installiere PDF-Reader / Document-Parser (poppler-utils, tesseract-ocr)...${NC}"
sudo apt-get install -y poppler-utils tesseract-ocr

# 3. Installation von Zotero (Desktop-Anwendung, hier nur Vorbereitung oder CLI-Integration)
# Zotero ist primär eine Desktop-Anwendung. Hier wird eine CLI-Integration oder die Vorbereitung für die Desktop-Installation vorgenommen.
echo -e "${BLUE}Bereite Zotero-Integration vor (manuelle Desktop-Installation empfohlen)...${NC}"
echo -e "${YELLOW}Hinweis: Zotero ist eine Desktop-Anwendung. Bitte installiere Zotero manuell auf deinem System.${NC}"
echo -e "${YELLOW}Besuche https://www.zotero.org/download/ für die Installation.${NC}"
# Hier könnte ein Skript zum Download des .deb-Pakets stehen oder eine CLI-Integration, falls verfügbar.

# 4. Konfiguration für OpenClaw Skills (falls spezifische Skills für Rechtsdatenbanken existieren)
echo -e "${BLUE}Konfiguriere OpenClaw für juristische Skills...${NC}"
# Hier könnten Skripte aufgerufen werden, die OpenClaw-Skills für juristische Datenbanken konfigurieren.
# Beispiel: $INSTALL_DIR/scripts/openclaw_skill_config.sh --skill legal_db_search

echo -e "${GREEN}Profil 'Rechtsberatung & Steuerrecht' Installation abgeschlossen.${NC}"
