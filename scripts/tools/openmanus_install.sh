#!/bin/bash
# ==============================================================================
# OPENMANUS_INSTALL.SH - Installation von OpenManus
# ==============================================================================

GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

OPENMANUS_DIR="/opt/openmanus"

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
    git clone https://github.com/openmanus/openmanus.git "$OPENMANUS_DIR"
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
