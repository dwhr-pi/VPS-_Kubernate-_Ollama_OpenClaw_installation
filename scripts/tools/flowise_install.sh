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
# shellcheck source=../lib/git_target_repair.sh
source "$INSTALL_DIR/scripts/lib/git_target_repair.sh"
init_tool_tracking "Flowise"

FLOWISE_DIR="/opt/flowise"
FLOWISE_REPO_URL="${FLOWISE_REPO_URL:-https://github.com/FlowiseAI/Flowise.git}"
FLOWISE_MIN_LINUX_DISK_MB="${FLOWISE_MIN_LINUX_DISK_MB:-8192}"
FLOWISE_MIN_WINDOWS_C_MB="${FLOWISE_MIN_WINDOWS_C_MB:-20480}"
FLOWISE_MIN_RAM_MB="${FLOWISE_MIN_RAM_MB:-4096}"

fail_with_hint() {
    echo -e "${RED}Fehler: $1${NC}"
    shift || true
    for hint in "$@"; do
        echo -e "${YELLOW}${hint}${NC}"
    done
    exit 1
}

available_mb_for_path() {
    local path="$1"
    df -Pm "$path" 2>/dev/null | awk 'NR==2 {print $4}'
}

available_ram_mb() {
    awk '/MemAvailable:/ {print int($2 / 1024)}' /proc/meminfo 2>/dev/null || echo 0
}

is_wsl2() {
    grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

require_min_mb() {
    local label="$1"
    local actual="$2"
    local required="$3"
    if [ "${actual:-0}" -lt "$required" ]; then
        fail_with_hint "${label} zu niedrig fuer Flowise." \
            "${label}: ${actual:-0} MB verfuegbar, erforderlich: ${required} MB." \
            "Flowise ist ein groesseres Node/pnpm-Projekt; der Build soll nicht erst nach langer Laufzeit abbrechen."
    fi
}

prepare_flowise_node_environment() {
    local node_bin="${FLOWISE_NODE_BIN:-}"
    local node_version
    local node_major

    if [ -n "$node_bin" ]; then
        [ -x "$node_bin" ] || fail_with_hint "FLOWISE_NODE_BIN ist nicht ausfuehrbar: $node_bin" \
            "Bitte auf ein Node-20.x-Binary zeigen lassen, z. B. FLOWISE_NODE_BIN=/pfad/zu/node."
        export PATH="$(dirname "$node_bin"):$PATH"
    else
        command -v node >/dev/null 2>&1 || fail_with_hint "Node.js wurde nicht gefunden." \
            "Flowise benoetigt Node.js 20.x." \
            "Installiere Node 20 bewusst separat oder setze FLOWISE_NODE_BIN=/pfad/zu/node20."
        node_bin="$(command -v node)"
    fi

    node_version="$("$node_bin" -p 'process.versions.node' 2>/dev/null || true)"
    node_major="${node_version%%.*}"
    if [ "$node_major" != "20" ] && [ "${FLOWISE_ALLOW_NODE_MISMATCH:-false}" != "true" ]; then
        fail_with_hint "Flowise erwartet Node.js 20.x, gefunden wurde Node ${node_version:-unbekannt} (${node_bin})." \
            "Der Installer startet deshalb keinen langen pnpm-Build mit inkompatibler Node-Version." \
            "Nutze Node 20.x und starte erneut, z. B. FLOWISE_NODE_BIN=/pfad/zu/node20 bash scripts/tools/flowise_install.sh" \
            "Nur wenn du das Risiko bewusst tragen willst: FLOWISE_ALLOW_NODE_MISMATCH=true setzen."
    fi

    command -v pnpm >/dev/null 2>&1 || fail_with_hint "pnpm wurde nicht gefunden." \
        "Aktiviere pnpm z. B. mit Corepack fuer deine Node-20-Umgebung: corepack enable && corepack prepare pnpm@latest --activate"
}

preflight_flowise_resources() {
    local linux_disk_mb
    local windows_c_mb
    local ram_mb

    linux_disk_mb="$(available_mb_for_path /)"
    ram_mb="$(available_ram_mb)"
    echo -e "${YELLOW}Flowise Preflight: Linux-/WSL-Speicher frei: ${linux_disk_mb:-0} MB, RAM verfuegbar: ${ram_mb:-0} MB.${NC}"
    require_min_mb "Linux-/WSL-Speicher" "${linux_disk_mb:-0}" "$FLOWISE_MIN_LINUX_DISK_MB"
    require_min_mb "RAM" "${ram_mb:-0}" "$FLOWISE_MIN_RAM_MB"

    if is_wsl2 && [ -d /mnt/c ] && [ "${FLOWISE_SKIP_WINDOWS_DISK_CHECK:-false}" != "true" ]; then
        windows_c_mb="$(available_mb_for_path /mnt/c)"
        echo -e "${YELLOW}Flowise Preflight: Windows-C:-Speicher frei: ${windows_c_mb:-0} MB.${NC}"
        require_min_mb "Windows-C:-Speicher" "${windows_c_mb:-0}" "$FLOWISE_MIN_WINDOWS_C_MB"
    fi
}

echo -e "${BLUE}Starte Installation von Flowise...${NC}"
echo -e "${YELLOW}Hinweis: Flowise ist ein Node/pnpm-Projekt. Unter WSL2/MiniPC vorher RAM, Swap und freien Windows-C:-Speicher pruefen.${NC}"
echo -e "${YELLOW}GitHub-Quelle: ${FLOWISE_REPO_URL}${NC}"
preflight_flowise_resources
prepare_flowise_node_environment

# 1. Flowise aus GitHub klonen
if [ -d "$FLOWISE_DIR" ]; then
    repair_git_target_for_clone "$FLOWISE_DIR" "$FLOWISE_REPO_URL" "Flowise"
    if [ -d "$FLOWISE_DIR/.git" ]; then
        echo -e "${YELLOW}Flowise Verzeichnis $FLOWISE_DIR existiert bereits. Aktualisiere Repository...${NC}"
        cd "$FLOWISE_DIR"
        if ! GIT_TERMINAL_PROMPT=0 git pull --ff-only; then
            echo -e "${RED}Fehler: Flowise-Update fehlgeschlagen. Build wird nicht fortgesetzt.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Flowise Zielordner wurde repariert. Klone neu...${NC}"
        GIT_TERMINAL_PROMPT=0 git clone "$FLOWISE_REPO_URL" "$FLOWISE_DIR"
        cd "$FLOWISE_DIR"
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
