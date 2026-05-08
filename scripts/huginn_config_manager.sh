#!/bin/bash
# ==============================================================================
# HUGINN_CONFIG_MANAGER.SH - Verwaltet die Huginn-.env-Vorlage und Laufzeitdatei
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
HUGINN_TEMPLATE_DIR="$USER_WORKSPACE_DIR/huginn"
HUGINN_TEMPLATE_FILE="$HUGINN_TEMPLATE_DIR/.env.template"
HUGINN_REPO_TEMPLATE_FILE="$INSTALL_DIR/scripts/config_templates/huginn/.env.template"
HUGINN_INSTALL_DIR="/opt/huginn"
HUGINN_RUNTIME_ENV="$HUGINN_INSTALL_DIR/.env"
HUGINN_CONFIG_CHOICE_FILE="/tmp/huginn_config_choice"

ensure_user_workspace() {
    mkdir -p "$HUGINN_TEMPLATE_DIR"

    if [ ! -f "$HUGINN_TEMPLATE_FILE" ]; then
        if [ -f "$HUGINN_REPO_TEMPLATE_FILE" ]; then
            cp "$HUGINN_REPO_TEMPLATE_FILE" "$HUGINN_TEMPLATE_FILE"
        else
            touch "$HUGINN_TEMPLATE_FILE"
        fi
    fi
}

cleanup_temp_files() {
    rm -f "$HUGINN_CONFIG_CHOICE_FILE"
}

pause_screen() {
    read -r -p "Druecken Sie Enter..."
}

edit_file() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        echo -e "${RED}Fehler: Datei nicht gefunden: ${file_path}${NC}"
        pause_screen
        return 1
    fi

    echo -e "${BLUE}Oeffne Datei zum Bearbeiten: ${file_path}${NC}"
    echo -e "${YELLOW}Hinweis: Die Huginn-Doku zur .env steht in docs/HUGINN_ENV_GUIDE.md${NC}"
    echo -e "${YELLOW}Bearbeitbare Vorlage: ${HUGINN_TEMPLATE_FILE}${NC}"
    echo -e "${YELLOW}Laufzeitdatei in Huginn: ${HUGINN_RUNTIME_ENV}${NC}"
    if command -v nano >/dev/null 2>&1; then
        nano "$file_path"
    elif command -v vi >/dev/null 2>&1; then
        vi "$file_path"
    else
        echo -e "${RED}Kein geeigneter Texteditor (nano oder vi) gefunden. Bitte bearbeiten Sie die Datei manuell: ${file_path}${NC}"
        pause_screen
    fi
}

apply_env_template() {
    ensure_user_workspace

    if [ ! -f "$HUGINN_TEMPLATE_FILE" ]; then
        echo -e "${RED}Fehler: Vorlagendatei ${HUGINN_TEMPLATE_FILE} nicht gefunden.${NC}"
        return 1
    fi

    if [ ! -d "$HUGINN_INSTALL_DIR" ]; then
        echo -e "${YELLOW}Warnung: Huginn ist noch nicht unter ${HUGINN_INSTALL_DIR} installiert.${NC}"
        echo -e "${YELLOW}Die Vorlage wurde nicht angewendet, kann aber schon vorbereitet werden.${NC}"
        return 1
    fi

    echo -e "${BLUE}Wende Huginn-.env auf ${HUGINN_RUNTIME_ENV} an...${NC}"
    sudo cp "$HUGINN_TEMPLATE_FILE" "$HUGINN_RUNTIME_ENV"
    sudo chown "$USER:$USER" "$HUGINN_RUNTIME_ENV" 2>/dev/null || true
    sudo chmod 600 "$HUGINN_RUNTIME_ENV" 2>/dev/null || true
    echo -e "${GREEN}Huginn-.env erfolgreich angewendet.${NC}"
}

import_runtime_env() {
    ensure_user_workspace

    if [ ! -f "$HUGINN_RUNTIME_ENV" ]; then
        echo -e "${YELLOW}Es gibt aktuell keine Laufzeitdatei unter ${HUGINN_RUNTIME_ENV}.${NC}"
        echo -e "${YELLOW}Die Vorlage bleibt unveraendert.${NC}"
        return 1
    fi

    cp "$HUGINN_RUNTIME_ENV" "$HUGINN_TEMPLATE_FILE"
    chmod 600 "$HUGINN_TEMPLATE_FILE" 2>/dev/null || true
    echo -e "${GREEN}Die aktuelle Huginn-.env wurde in die bearbeitbare Vorlage uebernommen.${NC}"
}

show_huginn_paths() {
    echo -e "${BLUE}Huginn-Konfigurationspfade${NC}"
    echo -e "${YELLOW}Bearbeitbare Vorlage: ${HUGINN_TEMPLATE_FILE}${NC}"
    echo -e "${YELLOW}Laufzeitdatei: ${HUGINN_RUNTIME_ENV}${NC}"
    echo -e "${YELLOW}Guide: docs/HUGINN_ENV_GUIDE.md${NC}"
    echo -e "${YELLOW}Tipp: Oeffentliche Freigaben nur ueber Reverse Proxy, Cloudflare Tunnel oder Tailscale.${NC}"
    pause_screen
}

show_huginn_config_menu() {
    rm -f "$HUGINN_CONFIG_CHOICE_FILE"
    dialog --clear --backtitle "OpenClaw Ultimate Setup" \
        --cancel-label "Zurueck" \
        --title "HUGINN .env KONFIGURATION" --menu "Waehlen Sie eine Aktion fuer die Huginn-.env:" 20 100 10 \
        "1" "Huginn-.env-Vorlage bearbeiten" \
        "2" "Vorlage auf /opt/huginn/.env anwenden" \
        "3" "Aktuelle /opt/huginn/.env in Vorlage uebernehmen" \
        "4" "Pfade und Hinweise anzeigen" \
        "5" "Beenden" 2> "$HUGINN_CONFIG_CHOICE_FILE"
}

main() {
    trap cleanup_temp_files EXIT
    ensure_user_workspace

    while true; do
        show_huginn_config_menu
        [ -f "$HUGINN_CONFIG_CHOICE_FILE" ] || break

        case "$(cat "$HUGINN_CONFIG_CHOICE_FILE")" in
            1)
                edit_file "$HUGINN_TEMPLATE_FILE"
                ;;
            2)
                apply_env_template
                pause_screen
                ;;
            3)
                import_runtime_env
                pause_screen
                ;;
            4)
                show_huginn_paths
                ;;
            5)
                break
                ;;
            *)
                break
                ;;
        esac
    done
}

main "$@"
