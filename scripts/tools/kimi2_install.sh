#!/bin/bash
# ==============================================================================
# KIMI2_INSTALL.SH - Installiert Kimi 2 (Moonshot AI) von GitHub
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

KIMI2_REPO="https://github.com/moonshot-ai/kimi2.git" # Beispiel-Repo, anpassen falls offizielles Repo existiert
KIMI2_DIR="/opt/kimi2"

echo -e "${BLUE}Starte Installation von Kimi 2...${NC}"

# Prüfen, ob Kimi 2 bereits installiert ist
if [ -d "$KIMI2_DIR" ]; then
    echo -e "${YELLOW}Kimi 2 ist bereits installiert unter ${KIMI2_DIR}. Überspringe Installation.${NC}"
    exit 0
fi

# Abhängigkeiten installieren
echo -e "${BLUE}Installiere System-Abhängigkeiten für Kimi 2...${NC}"
sudo apt update
sudo apt install -y git python3 python3-pip python3-venv

# Kimi 2 Repository klonen
echo -e "${BLUE}Klone Kimi 2 Repository von ${KIMI2_REPO}...${NC}"
sudo git clone "$KIMI2_REPO" "$KIMI2_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler beim Klonen des Kimi 2 Repositories.${NC}"
    exit 1
fi

# Virtuelle Umgebung erstellen und aktivieren
echo -e "${BLUE}Erstelle und aktiviere virtuelle Umgebung für Kimi 2...${NC}"
sudo python3 -m venv "$KIMI2_DIR/venv"
source "$KIMI2_DIR/venv/bin/activate"

# Python-Abhängigkeiten installieren
echo -e "${BLUE}Installiere Python-Abhängigkeiten für Kimi 2...${NC}"
pip install --no-cache-dir -r "$KIMI2_DIR/requirements.txt"
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler beim Installieren der Python-Abhängigkeiten für Kimi 2.${NC}"
    deactivate
    exit 1
fi

# Deaktiviere virtuelle Umgebung
deactivate

echo -e "${GREEN}Kimi 2 erfolgreich installiert unter ${KIMI2_DIR}.${NC}"
echo -e "${YELLOW}Bitte konfiguriere deinen Kimi 2 API-Key in der entsprechenden Konfigurationsdatei oder Umgebungsvariablen.${NC}"
