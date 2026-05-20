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
N8N_MIN_FREE_GB="${N8N_MIN_FREE_GB:-20}"
N8N_RECOMMENDED_FREE_GB="${N8N_RECOMMENDED_FREE_GB:-40}"

free_gb_for_path() {
    local path="$1"
    df -BG "$path" 2>/dev/null | awk 'NR==2 {gsub("G","",$4); print $4}'
}

check_n8n_disk_space() {
    local target_parent="/opt"
    local free_gb

    free_gb="$(free_gb_for_path "$target_parent")"
    if [ -z "$free_gb" ]; then
        free_gb="$(free_gb_for_path /)"
    fi

    echo -e "${BLUE}Speicherplatzpruefung fuer n8n GitHub-Build:${NC}"
    echo -e "${BLUE}- Freier Speicher auf $target_parent: ${free_gb:-unbekannt} GB${NC}"
    echo -e "${BLUE}- Geschaetzter Bedarf fuer n8n aus GitHub: ca. 5-15 GB dauerhaft, zusaetzlich temporaerer pnpm-/Build-Cache.${NC}"
    echo -e "${BLUE}- Empfohlen vor Start: ${N8N_RECOMMENDED_FREE_GB} GB frei; absolutes Minimum: ${N8N_MIN_FREE_GB} GB frei.${NC}"
    echo -e "${YELLOW}Hinweis: Der n8n-Monorepo-Build kann bei @n8n/chat:build mit 'Terminated' abbrechen, wenn RAM, Swap oder freier Speicher knapp sind.${NC}"

    if [ -n "$free_gb" ] && [ "$free_gb" -lt "$N8N_MIN_FREE_GB" ]; then
        echo -e "${RED}Fehler: Zu wenig freier Speicher fuer den n8n GitHub-Build. Bitte Speicher freigeben oder Zielsystem erweitern.${NC}"
        exit 1
    fi

    if [ -n "$free_gb" ] && [ "$free_gb" -lt "$N8N_RECOMMENDED_FREE_GB" ]; then
        echo -e "${YELLOW}Warnung: Der freie Speicher liegt unter der Empfehlung. Der Build kann trotzdem starten, aber Abbrueche sind wahrscheinlicher.${NC}"
    fi
}

echo -e "${BLUE}Starte Installation von n8n aus GitHub...${NC}"
check_n8n_disk_space

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
    echo -e "${RED}Fehler: pnpm build für n8n aus dem GitHub-Monorepo ist fehlgeschlagen.${NC}"
    echo -e "${YELLOW}Wenn im Log '@n8n/chat:build' und 'Terminated' steht, wurde der Build wahrscheinlich durch RAM-/Swap-/Speichermangel beendet.${NC}"
    echo -e "${YELLOW}Pruefe freien Speicher mit 'df -h', RAM/Swap mit 'free -h' und wiederhole danach die GitHub-Installation.${NC}"
    exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: n8n Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet n8n auf Port 5678.${NC}"

echo -e "${GREEN}n8n Installation abgeschlossen.${NC}"
mark_current_tool_installed
