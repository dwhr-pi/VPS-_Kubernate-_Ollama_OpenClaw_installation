#!/bin/bash
# ==============================================================================
# ACTIVEPIECES_INSTALL.SH - Installation von Activepieces
# Activepieces ist eine Open-Source-Alternative zu Zapier für Workflow-Automatisierung.
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
init_tool_tracking "Activepieces"

ACTIVEPIECES_DIR="/opt/activepieces"
ACTIVEPIECES_REPO_URL="${ACTIVEPIECES_REPO_URL:-https://github.com/activepieces/activepieces.git}"

echo -e "${BLUE}Starte Installation von Activepieces...${NC}"
echo -e "${YELLOW}Primaerquelle: ${ACTIVEPIECES_REPO_URL}${NC}"

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git ca-certificates curl build-essential
fi

if ! command -v pnpm >/dev/null 2>&1; then
    echo -e "${YELLOW}pnpm fehlt. Aktiviere pnpm ueber Corepack/NPM als Build-Werkzeug.${NC}"
    if command -v corepack >/dev/null 2>&1; then
        corepack enable
        corepack prepare pnpm@latest --activate
    elif command -v npm >/dev/null 2>&1; then
        sudo npm install -g pnpm
    else
        echo -e "${RED}Fehler: Weder pnpm noch corepack/npm gefunden.${NC}"
        exit 1
    fi
fi

clone_activepieces() {
    rm -rf "$ACTIVEPIECES_DIR"
    echo -e "${BLUE}Klone Activepieces in $ACTIVEPIECES_DIR...${NC}"
    if git clone --depth 1 --filter=blob:none "$ACTIVEPIECES_REPO_URL" "$ACTIVEPIECES_DIR"; then
        return 0
    fi

    echo -e "${YELLOW}Erster Clone-Versuch fehlgeschlagen. Versuche erneut mit HTTP/1.1 gegen HTTP/2-Abbrueche...${NC}"
    rm -rf "$ACTIVEPIECES_DIR"
    git -c http.version=HTTP/1.1 clone --depth 1 --filter=blob:none "$ACTIVEPIECES_REPO_URL" "$ACTIVEPIECES_DIR"
}

# 1. Activepieces aus GitHub klonen
sudo mkdir -p "$(dirname "$ACTIVEPIECES_DIR")"
sudo chown -R "$USER:$USER" "$(dirname "$ACTIVEPIECES_DIR")"

if [ -d "$ACTIVEPIECES_DIR/.git" ]; then
    echo -e "${YELLOW}Activepieces Verzeichnis $ACTIVEPIECES_DIR existiert bereits. Aktualisiere Repository...${NC}"
    if ! git -C "$ACTIVEPIECES_DIR" pull --ff-only; then
        echo -e "${RED}Fehler: Activepieces Repository konnte nicht aktualisiert werden.${NC}"
        echo -e "${YELLOW}Bitte lokale Aenderungen pruefen oder Activepieces deinstallieren und neu installieren.${NC}"
        exit 1
    fi
elif [ -e "$ACTIVEPIECES_DIR" ]; then
    echo -e "${YELLOW}Vorhandenes Activepieces-Verzeichnis ist kein vollstaendiger Git-Clone. Raeume unvollstaendige Installation auf...${NC}"
    clone_activepieces || {
        echo -e "${RED}Fehler: GitHub-Clone von Activepieces ist fehlgeschlagen.${NC}"
        rm -rf "$ACTIVEPIECES_DIR"
        exit 1
    }
else
    clone_activepieces || {
        echo -e "${RED}Fehler: GitHub-Clone von Activepieces ist fehlgeschlagen.${NC}"
        rm -rf "$ACTIVEPIECES_DIR"
        exit 1
    }
fi

cd "$ACTIVEPIECES_DIR"
if [ ! -f package.json ]; then
    echo -e "${RED}Fehler: Activepieces-Clone ist unvollstaendig, package.json fehlt in $ACTIVEPIECES_DIR.${NC}"
    echo -e "${YELLOW}pnpm wird bewusst nicht gestartet, damit der eigentliche Git-Fehler sichtbar bleibt.${NC}"
    exit 1
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Activepieces mit pnpm...${NC}"
if ! pnpm install; then
    echo -e "${RED}Fehler: pnpm install für Activepieces fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Activepieces bauen
echo -e "${BLUE}Baue Activepieces mit pnpm...${NC}"
if ! pnpm build; then
    echo -e "${RED}Fehler: pnpm build für Activepieces fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: Activepieces Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet Activepieces auf Port 3000.${NC}"

echo -e "${GREEN}Activepieces Installation abgeschlossen.${NC}"
mark_current_tool_installed
