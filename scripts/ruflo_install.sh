#!/bin/bash
# ==============================================================================
# RUFLO_INSTALL.SH - Ruflo Installation & Management
# Dieses Skript installiert Ruflo von GitHub und bietet Management-Optionen.
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

RUFLO_DIR="/opt/ruflo"

echo -e "${BLUE}Starte Ruflo Installation & Management...${NC}"

# 1. Ruflo aus GitHub klonen und bauen
echo -e "${GREEN}1/3: Ruflo aus GitHub klonen und bauen...${NC}"
if [ -d "$RUFLO_DIR" ]; then
    echo -e "${YELLOW}Ruflo Verzeichnis $RUFLO_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$RUFLO_DIR"
    git pull
else
    echo -e "${BLUE}Klone Ruflo in $RUFLO_DIR...${NC}"
    sudo mkdir -p "$RUFLO_DIR"
    sudo chown -R $USER:$USER "$RUFLO_DIR"
    git clone https://github.com/ruflo/ruflo.git "$RUFLO_DIR"
    cd "$RUFLO_DIR"
fi

echo -e "${BLUE}Installiere Ruflo Abhängigkeiten mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Ruflo fehlgeschlagen.${NC}"
    exit 1
fi

echo -e "${BLUE}Baue Ruflo mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Ruflo fehlgeschlagen.${NC}"
    exit 1
fi

# 2. Ruflo Konfiguration (Platzhalter)
echo -e "${GREEN}2/3: Ruflo Konfiguration vorbereiten...${NC}"
# Hier könnten Schritte zur Initialisierung der Ruflo-Konfiguration stehen
echo -e "${YELLOW}Hinweis: Ruflo Konfiguration muss eventuell manuell angepasst werden.${NC}"

# 3. Ruflo als Systemd Service einrichten (optional)
echo -e "${GREEN}3/3: Ruflo als Systemd Service einrichten (optional)...${NC}"
# Beispiel: sudo cp /path/to/ruflo.service /etc/systemd/system/
# sudo systemctl enable ruflo && sudo systemctl start ruflo
echo -e "${YELLOW}Hinweis: Systemd Service für Ruflo muss manuell erstellt und aktiviert werden, falls gewünscht.${NC}"

echo -e "${GREEN}Ruflo Installation & Management abgeschlossen.${NC}"
