#!/bin/bash
#
# Skript: Rechtsberatung_Steuerrecht_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum Profil 'Rechtsberatung & Steuerrecht' gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Profil 'Rechtsberatung & Steuerrecht' deinstalliert wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Deinstallation des Profils 'Rechtsberatung & Steuerrecht'...${NC}"

# 1. Deinstallation von Web-Search & Fetch Tools (Beispiel: pup, jq, wget, curl)
echo -e "${BLUE}Deinstalliere Web-Search & Fetch Tools (pup, jq, wget, curl)...${NC}"
sudo apt-get remove -y pup jq wget curl
sudo apt-get autoremove -y

# 2. Deinstallation von PDF-Reader / Document-Parser (Beispiel: poppler-utils, tesseract-ocr)
echo -e "${BLUE}Deinstalliere PDF-Reader / Document-Parser (poppler-utils, tesseract-ocr)...${NC}"
sudo apt-get remove -y poppler-utils tesseract-ocr
sudo apt-get autoremove -y

# 3. Deinstallation von Zotero (falls CLI-Integration vorgenommen wurde)
echo -e "${BLUE}Deinstalliere Zotero-Integration (falls vorhanden)...${NC}"
# Hier könnten Skripte zur Deinstallation von zotero-cli oder ähnlichem stehen.

# 4. Entfernen von OpenClaw Skills Konfigurationen (falls spezifische Skills für Rechtsdatenbanken existieren)
echo -e "${BLUE}Entferne OpenClaw Konfigurationen für juristische Skills...${NC}"
# Hier könnten Skripte aufgerufen werden, die OpenClaw-Skills für juristische Datenbanken dekonfigurieren.

echo -e "${GREEN}Profil 'Rechtsberatung & Steuerrecht' Deinstallation abgeschlossen.${NC}"
