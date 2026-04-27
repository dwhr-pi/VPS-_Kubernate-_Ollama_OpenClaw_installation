#!/bin/bash
# ==============================================================================
# CLAWBAKE_INSTALL.SH - Installation von Clawbake
# Clawbake ist ein Tool zur Automatisierung von Builds und Deployments.
# ==============================================================================

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
init_tool_tracking "Clawbake"

CLAWBAKE_DIR="/opt/clawbake"
CLAWBAKE_REPO_URL="${CLAWBAKE_REPO_URL:-https://github.com/openclaw/clawbake.git}"

echo -e "${BLUE}Starte Installation von Clawbake...${NC}"

if ! git ls-remote "$CLAWBAKE_REPO_URL" HEAD >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Clawbake Repository nicht erreichbar: ${CLAWBAKE_REPO_URL}${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf CLAWBAKE_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

# 1. Clawbake aus GitHub klonen
if [ -d "$CLAWBAKE_DIR" ]; then
    echo -e "${YELLOW}Clawbake Verzeichnis $CLAWBAKE_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$CLAWBAKE_DIR"
    git pull --ff-only
else
    echo -e "${BLUE}Klone Clawbake in $CLAWBAKE_DIR...${NC}"
    sudo mkdir -p "$CLAWBAKE_DIR"
    sudo chown -R $USER:$USER "$CLAWBAKE_DIR"
    git clone "$CLAWBAKE_REPO_URL" "$CLAWBAKE_DIR"
    cd "$CLAWBAKE_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Clawbake mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Clawbake fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Clawbake bauen
echo -e "${BLUE}Baue Clawbake mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Clawbake fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: Clawbake Konfiguration muss eventuell manuell angepasst werden.${NC}"

echo -e "${GREEN}Clawbake Installation abgeschlossen.${NC}"
mark_current_tool_installed

