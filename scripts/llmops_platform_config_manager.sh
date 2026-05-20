#!/bin/bash
# ==============================================================================
# LLMOPS_PLATFORM_CONFIG_MANAGER.SH - Verwaltet die LLMOps-Stack-.env
# Analog zum OpenClaw-Konfigurations-Manager, aber fuer stacks/llmops-platform.
# ==============================================================================

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

dialog() {
    local arg
    local has_cancel_label=0

    for arg in "$@"; do
        if [ "$arg" = "--cancel-label" ]; then
            has_cancel_label=1
            break
        fi
    done

    if [ "$has_cancel_label" -eq 1 ]; then
        command dialog "$@"
    else
        command dialog --cancel-label "Zurueck" "$@"
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
LLMOPS_TEMPLATE_DIR="$USER_WORKSPACE_DIR/llmops-platform"
LLMOPS_STACK_DIR="$INSTALL_DIR/stacks/llmops-platform"
LLMOPS_CHOICE_FILE="/tmp/llmops_platform_config_choice"

ensure_user_workspace() {
    mkdir -p "$LLMOPS_TEMPLATE_DIR"

    if [ ! -f "$LLMOPS_TEMPLATE_DIR/.env.template" ]; then
        cp "$INSTALL_DIR/scripts/config_templates/llmops-platform/.env.template" "$LLMOPS_TEMPLATE_DIR/.env.template"
    fi
}

cleanup_temp_files() {
    rm -f "$LLMOPS_CHOICE_FILE"
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
    echo -e "${YELLOW}Hinweis: Diese Vorlage ist fuer LiteLLM, Ollama, Open WebUI und OpenClaw-nahe Nutzung abgestimmt.${NC}"
    if command -v nano >/dev/null 2>&1; then
        nano "$file_path"
    elif command -v vi >/dev/null 2>&1; then
        vi "$file_path"
    else
        echo -e "${RED}Kein geeigneter Texteditor (nano oder vi) gefunden. Bitte bearbeiten Sie die Datei manuell: ${file_path}${NC}"
        pause_screen
    fi
}

apply_env() {
    local template_file="$LLMOPS_TEMPLATE_DIR/.env.template"
    local target_file="$LLMOPS_STACK_DIR/.env"

    if [ ! -f "$template_file" ]; then
        echo -e "${RED}Fehler: Vorlagendatei ${template_file} nicht gefunden.${NC}"
        return 1
    fi

    if [ ! -d "$LLMOPS_STACK_DIR" ]; then
        echo -e "${RED}Fehler: Stack-Verzeichnis ${LLMOPS_STACK_DIR} nicht gefunden.${NC}"
        return 1
    fi

    cp "$template_file" "$target_file"
    echo -e "${GREEN}LLMOps-Stack-.env erfolgreich nach ${target_file} angewendet.${NC}"
    echo -e "${YELLOW}Hinweis: Der Compose-Stack liest jetzt ${target_file} als Laufzeitdatei.${NC}"
}

show_menu() {
    rm -f "$LLMOPS_CHOICE_FILE"
    dialog --clear --backtitle "LLMOps Plattform Konfigurations-Manager" \
    --title "LLMOps Stack .env" --menu "Waehlen Sie eine Option:" 15 70 5 \
    "1" "Bearbeite .env Vorlage" \
    "2" "Wende .env Vorlage auf den Stack an" \
    "3" "Zurueck" 2> "$LLMOPS_CHOICE_FILE"
}

trap cleanup_temp_files EXIT

while true; do
    ensure_user_workspace
    show_menu

    if [ $? -ne 0 ] || [ ! -f "$LLMOPS_CHOICE_FILE" ]; then
        break
    fi

    CHOICE="$(tr -d '\r' < "$LLMOPS_CHOICE_FILE")"

    case "$CHOICE" in
        1)
            edit_file "$LLMOPS_TEMPLATE_DIR/.env.template"
            ;;
        2)
            apply_env
            pause_screen
            ;;
        3)
            break
            ;;
        *)
            echo -e "${RED}Ungueltige Auswahl. Bitte versuchen Sie es erneut.${NC}"
            sleep 2
            ;;
    esac
done
