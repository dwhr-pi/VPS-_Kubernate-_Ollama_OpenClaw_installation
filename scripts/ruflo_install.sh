#!/bin/bash
# ==============================================================================
# RUFLO_INSTALL.SH - Ruflo Installation & Management
# Dieses Skript installiert Ruflo von GitHub und bietet Management-Optionen.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

RUFLO_DIR="/opt/ruflo"
RUFLO_REPOS=(
    "${RUFLO_REPO_URL:-}"
    "https://github.com/ruvnet/ruflo.git"
    "https://github.com/dwhr-pi/ruflo.git"
)

echo -e "${BLUE}Starte Ruflo Installation & Management...${NC}"

RUFLO_REPO_URL=""
for repo in "${RUFLO_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        RUFLO_REPO_URL="$repo"
        break
    fi
done

if [ -z "$RUFLO_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Ruflo Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden ruvnet/ruflo und dwhr-pi/ruflo.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf RUFLO_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

# 1. Ruflo aus GitHub klonen und bauen
echo -e "${GREEN}1/3: Ruflo aus GitHub klonen und bauen...${NC}"
if [ -d "$RUFLO_DIR" ]; then
    echo -e "${YELLOW}Ruflo Verzeichnis $RUFLO_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$RUFLO_DIR"
    git pull --ff-only
else
    echo -e "${BLUE}Klone Ruflo in $RUFLO_DIR...${NC}"
    sudo mkdir -p "$RUFLO_DIR"
    sudo chown -R $USER:$USER "$RUFLO_DIR"
    git clone "$RUFLO_REPO_URL" "$RUFLO_DIR"
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
