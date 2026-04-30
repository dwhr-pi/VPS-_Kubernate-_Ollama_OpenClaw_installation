#!/bin/bash
# ==============================================================================
# AUTOGPT_INSTALL.SH - Installation von AutoGPT
# AutoGPT ist eine Agenten-Plattform von Significant Gravitas.
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
init_tool_tracking "AutoGPT"

AUTOGPT_DIR="/opt/autogpt"
AUTOGPT_PLATFORM_DIR="$AUTOGPT_DIR/autogpt_platform"
AUTOGPT_REPOS=(
    "${AUTOGPT_REPO_URL:-}"
    "https://github.com/significant-gravitas/autogpt.git"
    "https://github.com/dwhr-pi/AutoGPT.git"
)

echo -e "${BLUE}Starte Installation von AutoGPT...${NC}"

AUTOGPT_REPO_URL=""
for repo in "${AUTOGPT_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        AUTOGPT_REPO_URL="$repo"
        break
    fi
done

if [ -z "$AUTOGPT_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares AutoGPT Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden significant-gravitas/autogpt und dwhr-pi/AutoGPT.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf AUTOGPT_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

if [ -d "$AUTOGPT_DIR" ]; then
    echo -e "${YELLOW}AutoGPT Verzeichnis $AUTOGPT_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$AUTOGPT_DIR"
    git pull --ff-only
else
    echo -e "${BLUE}Klone AutoGPT in $AUTOGPT_DIR...${NC}"
    sudo mkdir -p "$AUTOGPT_DIR"
    sudo chown -R "$USER":"$USER" "$AUTOGPT_DIR"
    git clone "$AUTOGPT_REPO_URL" "$AUTOGPT_DIR"
    cd "$AUTOGPT_DIR"
fi

echo -e "${BLUE}Prüfe Docker-Abhängigkeiten für AutoGPT...${NC}"
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${YELLOW}Docker nicht gefunden, installiere docker.io...${NC}"
    sudo apt update
    sudo apt install -y docker.io
fi

if ! sudo docker compose version >/dev/null 2>&1; then
    echo -e "${YELLOW}Docker Compose Plugin nicht gefunden, installiere docker-compose-plugin...${NC}"
    sudo apt update
    sudo apt install -y docker-compose-plugin
fi

if ! command -v make >/dev/null 2>&1; then
    echo -e "${YELLOW}make nicht gefunden, installiere build-essential...${NC}"
    sudo apt update
    sudo apt install -y build-essential
fi

if ! command -v docker >/dev/null 2>&1 || ! sudo docker compose version >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Docker oder Docker Compose konnten nicht installiert werden.${NC}"
    exit 1
fi

sudo systemctl enable --now docker >/dev/null 2>&1 || true
sudo usermod -aG docker "$USER" >/dev/null 2>&1 || true

if [ ! -d "$AUTOGPT_PLATFORM_DIR" ]; then
    echo -e "${RED}Fehler: AutoGPT Plattform-Verzeichnis nicht gefunden: $AUTOGPT_PLATFORM_DIR${NC}"
    exit 1
fi

cd "$AUTOGPT_PLATFORM_DIR"

if [ ! -f ".env" ] && [ -f ".env.default" ]; then
    echo -e "${BLUE}Erstelle AutoGPT .env aus .env.default...${NC}"
    cp .env.default .env
fi

echo -e "${BLUE}Starte AutoGPT Plattform per Docker Compose...${NC}"
sudo docker compose up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: AutoGPT Docker Compose Start fehlgeschlagen.${NC}"
    exit 1
fi

echo -e "${GREEN}AutoGPT Installation abgeschlossen.${NC}"
echo -e "${YELLOW}Die Plattform liegt unter ${AUTOGPT_DIR}.${NC}"
echo -e "${YELLOW}Falls Docker gerade neu installiert wurde, kann eine neue Shell-Anmeldung für die Docker-Gruppe nötig sein.${NC}"
echo -e "${YELLOW}Die AutoGPT Plattform ist nach dem Start typischerweise unter http://localhost:3000 erreichbar.${NC}"
mark_current_tool_installed
