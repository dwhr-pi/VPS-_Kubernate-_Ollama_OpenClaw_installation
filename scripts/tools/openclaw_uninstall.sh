#!/bin/bash
# ==============================================================================
# OPENCLAW_UNINSTALL.SH - Deinstallation von OpenClaw
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
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/lib/common.sh"
init_tool_tracking "OpenClaw"

OPENCLAW_DIR="${OPENCLAW_DIR:-/opt/openclaw}"
OPENCLAW_UNINSTALL_ASSUME_YES="${OPENCLAW_UNINSTALL_ASSUME_YES:-false}"
OPENCLAW_STATE_DIR_DEFAULT="${HOME}/.openclaw"
OPENCLAW_BACKUP_ROOT="${HOME}/.openclaw_ultimate_user_data/backups/openclaw"
OPENCLAW_BACKUP_STATE="${OPENCLAW_BACKUP_STATE:-prompt}"
OPENCLAW_REMOVE_STATE="${OPENCLAW_REMOVE_STATE:-prompt}"

prompt_yes_no() {
    local prompt_text="$1"
    local default_answer="${2:-no}"
    local answer=""

    if [ "$OPENCLAW_UNINSTALL_ASSUME_YES" = "true" ]; then
        return 0
    fi

    if [ ! -t 0 ]; then
        [ "$default_answer" = "yes" ]
        return
    fi

    read -r -p "$prompt_text [ja/Nein]: " answer
    case "$answer" in
        ja|JA|j|J|yes|YES|y|Y) return 0 ;;
        nein|NEIN|n|N|no|NO) return 1 ;;
        "") [ "$default_answer" = "yes" ] ;;
        *) [ "$default_answer" = "yes" ] ;;
    esac
}

backup_openclaw_state_if_requested() {
    case "$OPENCLAW_BACKUP_STATE" in
        yes) ;;
        no) return 0 ;;
        *)
            if ! prompt_yes_no "Soll der OpenClaw-Status unter ${OPENCLAW_STATE_DIR_DEFAULT} vor der Deinstallation gesichert werden?" "yes"; then
                return 0
            fi
            ;;
    esac

    if [ ! -d "$OPENCLAW_STATE_DIR_DEFAULT" ]; then
        echo -e "${YELLOW}Hinweis: Kein OpenClaw-State-Verzeichnis unter ${OPENCLAW_STATE_DIR_DEFAULT} gefunden.${NC}"
        return 0
    fi

    mkdir -p "$OPENCLAW_BACKUP_ROOT"
    local target_archive="${OPENCLAW_BACKUP_ROOT}/openclaw_state_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -C "$HOME" -czf "$target_archive" ".openclaw"
    echo -e "${GREEN}OpenClaw-Status gesichert: ${target_archive}${NC}"
}

remove_openclaw_state_if_requested() {
    case "$OPENCLAW_REMOVE_STATE" in
        yes) ;;
        no) return 0 ;;
        *)
            if ! prompt_yes_no "Soll der lokale OpenClaw-Status unter ${OPENCLAW_STATE_DIR_DEFAULT} ebenfalls entfernt werden?" "no"; then
                return 0
            fi
            ;;
    esac

    if [ -d "$OPENCLAW_STATE_DIR_DEFAULT" ]; then
        rm -rf "$OPENCLAW_STATE_DIR_DEFAULT"
        echo -e "${GREEN}OpenClaw-Statusverzeichnis entfernt.${NC}"
    fi
}

echo -e "${BLUE}Starte Deinstallation von OpenClaw...${NC}"

backup_openclaw_state_if_requested

if [ -d "$OPENCLAW_DIR" ]; then
    echo -e "${YELLOW}Lösche OpenClaw Verzeichnis $OPENCLAW_DIR...${NC}"
    sudo rm -rf "$OPENCLAW_DIR"
    echo -e "${GREEN}OpenClaw erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}OpenClaw ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

remove_openclaw_state_if_requested

echo -e "${GREEN}OpenClaw Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed
