#!/bin/bash
# ==============================================================================
# OPENCLAW_CONFIG_MANAGER.SH - Verwaltet die OpenClaw Konfigurationsdateien
# Ermöglicht das Bearbeiten und Anwenden von .env und config.json Vorlagen.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OPENCLAW_CONFIG_TEMPLATES_DIR="$INSTALL_DIR/scripts/config_templates/openclaw"
OPENCLAW_INSTALL_DIR="/opt/openclaw"
OPENCLAW_CONFIG_CHOICE_FILE="/tmp/openclaw_config_choice"

cleanup_temp_files() {
    rm -f "$OPENCLAW_CONFIG_CHOICE_FILE"
}

pause_screen() {
    read -r -p "Drücken Sie Enter..."
}

edit_file() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        echo -e "${RED}Fehler: Datei nicht gefunden: ${file_path}${NC}"
        pause_screen
        return 1
    fi

    echo -e "${BLUE}Öffne Datei zum Bearbeiten: ${file_path}${NC}"
    echo -e "${YELLOW}Hinweis: Details zur OpenClaw-.env und zur originalen Vorlage stehen in docs/OPENCLAW_ENV_GUIDE.md${NC}"
    echo -e "${YELLOW}Hinweise zur Beschaffung von API-Schlüsseln stehen in docs/API_KEY_GUIDE.md${NC}"
    if command -v nano >/dev/null 2>&1; then
        nano "$file_path"
    elif command -v vi >/dev/null 2>&1; then
        vi "$file_path"
    else
        echo -e "${RED}Kein geeigneter Texteditor (nano oder vi) gefunden. Bitte bearbeiten Sie die Datei manuell: ${file_path}${NC}"
        pause_screen
    fi
}

apply_config() {
    local config_type="$1"
    local template_file="$OPENCLAW_CONFIG_TEMPLATES_DIR/${config_type}.template"
    local target_file="$OPENCLAW_INSTALL_DIR/${config_type}"

    if [ ! -f "$template_file" ]; then
        echo -e "${RED}Fehler: Vorlagendatei ${template_file} nicht gefunden.${NC}"
        return 1
    fi

    if [ ! -d "$OPENCLAW_INSTALL_DIR" ]; then
        echo -e "${YELLOW}Warnung: OpenClaw ist nicht unter ${OPENCLAW_INSTALL_DIR} installiert.${NC}"
        echo -e "${YELLOW}Die Vorlage wurde nicht angewendet, kann aber weiter bearbeitet werden.${NC}"
        return 1
    fi

    echo -e "${BLUE}Wende ${config_type} Konfiguration an...${NC}"
    if sudo cp "$template_file" "$target_file"; then
        echo -e "${GREEN}Konfiguration ${config_type} erfolgreich auf OpenClaw angewendet.${NC}"
    else
        echo -e "${RED}Fehler beim Anwenden der Konfiguration ${config_type}.${NC}"
        return 1
    fi
}

show_openclaw_config_menu() {
    rm -f "$OPENCLAW_CONFIG_CHOICE_FILE"
    dialog --clear --backtitle "OpenClaw Konfigurations-Manager" \
    --title "OpenClaw Konfiguration" --menu "Wählen Sie eine Option:" 15 60 5 \
    "1" "Bearbeite .env Vorlage" \
    "2" "Wende .env Vorlage auf OpenClaw an" \
    "3" "Bearbeite config.json Vorlage" \
    "4" "Wende config.json Vorlage auf OpenClaw an" \
    "5" "Zurück zum Hauptmenü" 2> "$OPENCLAW_CONFIG_CHOICE_FILE"
}

trap cleanup_temp_files EXIT

while true; do
    show_openclaw_config_menu

    if [ $? -ne 0 ] || [ ! -f "$OPENCLAW_CONFIG_CHOICE_FILE" ]; then
        break
    fi

    CHOICE="$(tr -d '\r' < "$OPENCLAW_CONFIG_CHOICE_FILE")"

    case "$CHOICE" in
        1)
            edit_file "$OPENCLAW_CONFIG_TEMPLATES_DIR/.env.template"
            ;;
        2)
            apply_config ".env"
            pause_screen
            ;;
        3)
            edit_file "$OPENCLAW_CONFIG_TEMPLATES_DIR/config.json.template"
            ;;
        4)
            apply_config "config.json"
            pause_screen
            ;;
        5)
            break
            ;;
        *)
            echo -e "${RED}Ungültige Auswahl. Bitte versuchen Sie es erneut.${NC}"
            sleep 2
            ;;
    esac
done
