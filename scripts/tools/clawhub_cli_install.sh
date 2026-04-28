#!/bin/bash
# ==============================================================================
# CLAWHUB_CLI_INSTALL.SH - Installation von Clawhub CLI
# Clawhub CLI ist ein Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten.
# ==============================================================================

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Clawhub_CLI"

CLAWHUB_CLI_DIR="/opt/clawhub-cli"
CLAWHUB_CLI_REPOS=(
    "${CLAWHUB_CLI_REPO_URL:-}"
    "https://github.com/openclaw/clawhub-cli.git"
    "https://github.com/openclaw/clawhub.git"
    "https://github.com/dwhr-pi/clawhub.git"
)

echo -e "${BLUE}Starte Installation von Clawhub CLI...${NC}"

CLAWHUB_CLI_REPO_URL=""
for repo in "${CLAWHUB_CLI_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if GIT_TERMINAL_PROMPT=0 git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        CLAWHUB_CLI_REPO_URL="$repo"
        break
    fi
done

if [ -z "$CLAWHUB_CLI_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Clawhub CLI/Clawhub Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden openclaw/clawhub-cli, openclaw/clawhub und dwhr-pi/clawhub.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf CLAWHUB_CLI_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

# 1. Clawhub CLI aus GitHub klonen
if [ -d "$CLAWHUB_CLI_DIR" ]; then
    echo -e "${YELLOW}Clawhub CLI Verzeichnis $CLAWHUB_CLI_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$CLAWHUB_CLI_DIR"
    GIT_TERMINAL_PROMPT=0 git pull --ff-only
else
    echo -e "${BLUE}Klone Clawhub CLI in $CLAWHUB_CLI_DIR...${NC}"
    sudo mkdir -p "$CLAWHUB_CLI_DIR"
    sudo chown -R $USER:$USER "$CLAWHUB_CLI_DIR"
    GIT_TERMINAL_PROMPT=0 git clone "$CLAWHUB_CLI_REPO_URL" "$CLAWHUB_CLI_DIR"
    cd "$CLAWHUB_CLI_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Clawhub CLI mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Clawhub CLI fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Clawhub CLI bauen
echo -e "${BLUE}Baue Clawhub CLI mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Clawhub CLI fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Verknüpfung erstellen (optional)
echo -e "${BLUE}Erstelle symbolische Verknüpfung für einfachen Zugriff...${NC}"
if [ -f "$CLAWHUB_CLI_DIR/bin/run" ]; then
    sudo ln -sf "$CLAWHUB_CLI_DIR/bin/run" /usr/local/bin/clawhub
else
    echo -e "${YELLOW}Hinweis: Kein dediziertes CLI-Binary unter bin/run gefunden. Möglicherweise ist die CLI bereits in Clawhub integriert.${NC}"
fi

echo -e "${GREEN}Clawhub CLI Installation abgeschlossen. Du kannst es jetzt mit 'clawhub' aufrufen.${NC}"
mark_current_tool_installed
