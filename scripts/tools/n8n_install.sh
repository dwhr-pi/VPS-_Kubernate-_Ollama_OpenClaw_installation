#!/bin/bash
# ==============================================================================
# N8N_INSTALL.SH - Installation von n8n
# n8n ist ein Workflow-Automatisierungstool, das viele Apps und Dienste verbindet.
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
init_tool_tracking "n8n"

N8N_DIR="/opt/n8n"
N8N_RUNTIME_DIR="/opt/n8n-runtime"

install_n8n_runtime_fallback() {
    echo -e "${YELLOW}Der Build aus den aktuellen GitHub-Quellen ist fehlgeschlagen. Es wird eine stabilere Runtime-Installation als Fallback vorbereitet.${NC}"

    sudo mkdir -p "$N8N_RUNTIME_DIR"
    sudo chown -R "$USER:$USER" "$N8N_RUNTIME_DIR"
    cd "$N8N_RUNTIME_DIR"

    if [ ! -f package.json ]; then
        npm init -y >/dev/null 2>&1
    fi

    echo -e "${BLUE}Installiere n8n Runtime-Paket lokal mit npm...${NC}"
    npm install n8n
    if [ $? -ne 0 ]; then
        echo -e "${RED}Fehler: Auch die Runtime-Fallback-Installation von n8n ist fehlgeschlagen.${NC}"
        return 1
    fi

    sudo ln -sf "$N8N_RUNTIME_DIR/node_modules/.bin/n8n" /usr/local/bin/n8n
    echo -e "${YELLOW}Hinweis: n8n wurde als stabile Runtime-Fallback-Installation eingerichtet. Der Quellcode-Build aus dem GitHub-Monorepo blieb fehlerhaft.${NC}"
    return 0
}

echo -e "${BLUE}Starte Installation von n8n...${NC}"

# 1. n8n aus GitHub klonen
if [ -d "$N8N_DIR" ]; then
    echo -e "${YELLOW}n8n Verzeichnis $N8N_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$N8N_DIR"
    git pull
else
    echo -e "${BLUE}Klone n8n in $N8N_DIR...${NC}"
    sudo mkdir -p "$N8N_DIR"
    sudo chown -R $USER:$USER "$N8N_DIR"
    git clone https://github.com/n8n-io/n8n.git "$N8N_DIR"
    cd "$N8N_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für n8n mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für n8n fehlgeschlagen.${NC}"
    exit 1
fi

# 3. n8n bauen
echo -e "${BLUE}Baue n8n mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Warnung: pnpm build für n8n aus dem Monorepo ist fehlgeschlagen.${NC}"
    if ! install_n8n_runtime_fallback; then
        echo -e "${RED}Fehler: pnpm build für n8n fehlgeschlagen und auch der Runtime-Fallback konnte nicht eingerichtet werden.${NC}"
        exit 1
    fi
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: n8n Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet n8n auf Port 5678.${NC}"

echo -e "${GREEN}n8n Installation abgeschlossen.${NC}"
mark_current_tool_installed
