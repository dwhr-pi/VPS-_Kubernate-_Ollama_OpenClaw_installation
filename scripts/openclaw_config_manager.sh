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

INSTALL_DIR="$(pwd)"
OPENCLAW_CONFIG_TEMPLATES_DIR="$INSTALL_DIR/scripts/config_templates/openclaw"
OPENCLAW_INSTALL_DIR="/opt/openclaw"

# Funktion zum Bearbeiten einer Datei
edit_file() {
    FILE_PATH=$1
    echo -e "${BLUE}Öffne Datei zum Bearbeiten: ${FILE_PATH}${NC}"
    # Prüfen, ob nano oder vi verfügbar ist
    if command -v nano >/dev/null 2>&1; then
        nano "$FILE_PATH"
    elif command -v vi >/dev/null 2>&1; then
        vi "$FILE_PATH"
    else
        echo -e "${RED}Kein geeigneter Texteditor (nano oder vi) gefunden. Bitte bearbeiten Sie die Datei manuell: ${FILE_PATH}${NC}"
        read -p "Drücken Sie Enter, wenn Sie fertig sind..."
    fi
}

# Funktion zum Anwenden der Konfiguration
apply_config() {
    CONFIG_TYPE=$1 # .env oder config.json
    TEMPLATE_FILE="$OPENCLAW_CONFIG_TEMPLATES_DIR/${CONFIG_TYPE}.template"
    TARGET_FILE="$OPENCLAW_INSTALL_DIR/${CONFIG_TYPE}"

    if [ ! -f "$TEMPLATE_FILE" ]; then
        echo -e "${RED}Fehler: Vorlagendatei ${TEMPLATE_FILE} nicht gefunden.${NC}"
        return 1
    fi

    if [ ! -d "$OPENCLAW_INSTALL_DIR" ]; then
        echo -e "${YELLOW}Warnung: OpenClaw ist nicht unter ${OPENCLAW_INSTALL_DIR} installiert. Konfiguration wird nur in die Vorlage geschrieben.${NC}"
        echo -e "${BLUE}Möchten Sie die Konfiguration trotzdem in die Vorlage schreiben? (j/n)${NC}"
        read -r -p "" response
        if [[ "$response" =~ ^([jJ][aA]|[jJ])$ ]]; then
            echo -e "${BLUE}Konfiguration in Vorlage ${TEMPLATE_FILE} geschrieben.${NC}"
            return 0
        else
            echo -e "${YELLOW}Vorgang abgebrochen.${NC}"
            return 1
        fi
    fi

    echo -e "${BLUE}Wende ${CONFIG_TYPE} Konfiguration an...${NC}"
    sudo cp "$TEMPLATE_FILE" "$TARGET_FILE"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Konfiguration ${CONFIG_TYPE} erfolgreich auf OpenClaw angewendet.${NC}"
    else
        echo -e "${RED}Fehler beim Anwenden der Konfiguration ${CONFIG_TYPE}.${NC}"
        return 1
    fi
}

# Hauptmenü für OpenClaw Konfiguration
show_openclaw_config_menu() {
    dialog --clear --backtitle "OpenClaw Konfigurations-Manager" \
    --title "OpenClaw Konfiguration" --menu "Wählen Sie eine Option:" 15 60 5 \
    "1" "Bearbeite .env Vorlage" \
    "2" "Wende .env Vorlage auf OpenClaw an" \
    "3" "Bearbeite config.json Vorlage" \
    "4" "Wende config.json Vorlage auf OpenClaw an" \
    "5" "Zurück zum Hauptmenü" 2> /tmp/openclaw_config_choice
}

while true; do
    show_openclaw_config_menu
    CHOICE=$(cat /tmp/openclaw_config_choice)

    case $CHOICE in
        1)
            edit_file "$OPENCLAW_CONFIG_TEMPLATES_DIR/.env.template"
            ;;
        2)
            apply_config ".env"
            read -p "Drücken Sie Enter..."
            ;;
        3)
            edit_file "$OPENCLAW_CONFIG_TEMPLATES_DIR/config.json.template"
            ;;
        4)
            apply_config "config.json"
            read -p "Drücken Sie Enter..."
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

rm -f /tmp/openclaw_config_choice
