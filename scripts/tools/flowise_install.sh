#!/usr/bin/env bash
# ==============================================================================
# FLOWISE_INSTALL.SH - Installation von Flowise
# Flowise ist ein Open-Source-UI für LLM-Anwendungen, basierend auf LangchainJS.
# ==============================================================================
set -euo pipefail

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
init_tool_tracking "Flowise"

FLOWISE_DIR="/opt/flowise"
FLOWISE_REPO_URL="${FLOWISE_REPO_URL:-https://github.com/FlowiseAI/Flowise.git}"

echo -e "${BLUE}Starte Installation von Flowise...${NC}"
echo -e "${YELLOW}Hinweis: Flowise ist ein Node/pnpm-Projekt. Unter WSL2/MiniPC vorher RAM, Swap und freien Windows-C:-Speicher pruefen.${NC}"
echo -e "${YELLOW}GitHub-Quelle: ${FLOWISE_REPO_URL}${NC}"

# 1. Flowise aus GitHub klonen
if [ -d "$FLOWISE_DIR" ]; then
    if [ -d "$FLOWISE_DIR/.git" ]; then
        echo -e "${YELLOW}Flowise Verzeichnis $FLOWISE_DIR existiert bereits. Aktualisiere Repository...${NC}"
        cd "$FLOWISE_DIR"
        if ! GIT_TERMINAL_PROMPT=0 git pull --ff-only; then
            echo -e "${RED}Fehler: Flowise-Update fehlgeschlagen. Build wird nicht fortgesetzt.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Fehler: $FLOWISE_DIR existiert, ist aber kein Git-Repository.${NC}"
        echo -e "${YELLOW}Das passiert haeufig nach einem abgebrochenen Clone. Bitte manuell pruefen und erst dann entfernen:${NC}"
        echo -e "${YELLOW}  sudo rm -rf $FLOWISE_DIR${NC}"
        echo -e "${YELLOW}Danach den Installer erneut starten. Das Setup loescht diesen Ordner nicht automatisch.${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}Klone Flowise in $FLOWISE_DIR...${NC}"
    sudo mkdir -p "$FLOWISE_DIR"
    sudo chown -R "$USER":"$USER" "$FLOWISE_DIR"
    if ! GIT_TERMINAL_PROMPT=0 git clone "$FLOWISE_REPO_URL" "$FLOWISE_DIR"; then
        echo -e "${RED}Fehler: Flowise konnte nicht aus GitHub geklont werden.${NC}"
        echo -e "${YELLOW}Erwartete oeffentliche Quelle: https://github.com/FlowiseAI/Flowise.git${NC}"
        echo -e "${YELLOW}Wenn Git nach Username/Passwort fragt, ist die Repo-URL falsch, privat oder nicht erreichbar.${NC}"
        echo -e "${YELLOW}Dieses Setup nutzt bewusst keine GitHub-Passwortabfrage fuer oeffentliche Tools.${NC}"
        exit 1
    fi
    cd "$FLOWISE_DIR"
fi

if [ ! -f "$FLOWISE_DIR/package.json" ]; then
    echo -e "${RED}Fehler: In $FLOWISE_DIR wurde keine package.json gefunden.${NC}"
    echo -e "${YELLOW}Flowise wurde nicht korrekt geklont. pnpm install wird deshalb nicht gestartet.${NC}"
    exit 1
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für Flowise mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für Flowise fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Flowise bauen
echo -e "${BLUE}Baue Flowise mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für Flowise fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: Flowise Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet Flowise auf Port 3000.${NC}"

echo -e "${GREEN}Flowise Installation abgeschlossen.${NC}"
mark_current_tool_installed
