#!/bin/bash
#
# Skript: clawhub_install.sh
# Beschreibung: Dieses Skript installiert Clawhub, den zentralen Server für die Orchestrierung und Verwaltung von KI-Agenten, direkt aus seinem GitHub-Repository.
# Es klont das Repository, installiert Abhängigkeiten mit pnpm und baut das Projekt. Clawhub dient als Backend für die Clawhub CLI und andere Agenten.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn Clawhub über das Tool-Management ausgewählt wird.
#

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

CLAWHUB_DIR="/opt/clawhub"

echo -e "${BLUE}Starte Installation von Clawhub (Server)...${NC}"

# 1. Clawhub aus GitHub klonen
if [ -d "$CLAWHUB_DIR" ]; then
    echo -e "${YELLOW}Clawhub Verzeichnis $CLAWHUB_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$CLAWHUB_DIR"
    git pull
else
    echo -e "${BLUE}Klone Clawhub in $CLAWHUB_DIR...${NC}"
    sudo mkdir -p "$CLAWHUB_DIR"
    sudo chown -R $USER:$USER "$CLAWHUB_DIR"
    git clone https://github.com/openclaw/clawhub.git "$CLAWHUB_DIR"
    cd "$CLAWHUB_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Clawhub mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Clawhub fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Clawhub bauen
echo -e "${BLUE}Baue Clawhub mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Clawhub fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: Clawhub Konfiguration (z.B. Datenbank, API-Keys) und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet Clawhub auf Port 3000 (Beispiel).${NC}"

echo -e "${GREEN}Clawhub Installation abgeschlossen.${NC}"
