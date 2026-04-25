#!/bin/bash
# ==============================================================================
# KIMI2_INSTALL.SH - Installiert Kimi 2 (Moonshot AI) von GitHub
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

KIMI2_DIR="/opt/kimi2"
KIMI2_REPOS=(
    "${KIMI2_REPO:-}"
    "https://github.com/MoonshotAI/Kimi-K2.5.git"
    "https://github.com/dwhr-pi/AI-Kimi-K2.5.git"
)

echo -e "${BLUE}Starte Installation von Kimi 2...${NC}"

KIMI2_REPO=""
for repo in "${KIMI2_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        KIMI2_REPO="$repo"
        break
    fi
done

if [ -z "$KIMI2_REPO" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Kimi Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden MoonshotAI/Kimi-K2.5 und dwhr-pi/AI-Kimi-K2.5.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf KIMI2_REPO auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

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
