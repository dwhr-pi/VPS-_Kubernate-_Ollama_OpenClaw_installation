#!/bin/bash
# ==============================================================================
# OLLAMA_MODEL_MANAGER.SH - Ollama Modell-Management
# Dieses Skript bietet eine interaktive Oberfläche zur Verwaltung von Ollama-Modellen.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

OLLAMA_CHOICE_FILE="/tmp/ollama_choice"
MODEL_TO_INSTALL_FILE="/tmp/model_to_install"
MODEL_TO_UNINSTALL_FILE="/tmp/model_to_uninstall"

cleanup_temp_files() {
    rm -f "$OLLAMA_CHOICE_FILE" "$MODEL_TO_INSTALL_FILE" "$MODEL_TO_UNINSTALL_FILE"
}

ensure_ollama_available() {
    if ! command -v ollama >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Ollama ist nicht installiert. Bitte installieren Sie Ollama zuerst.${NC}"
        exit 1
    fi

    if ! ollama list >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Ollama ist installiert, aber der Dienst ist nicht erreichbar.${NC}"
        echo -e "${YELLOW}Bitte starten Sie Ollama zuerst, z.B. mit 'ollama serve' oder über den Systemdienst.${NC}"
        exit 1
    fi
}

show_ollama_menu() {
    rm -f "$OLLAMA_CHOICE_FILE"
    dialog --clear --backtitle "Ollama Modell-Manager" \
    --title "OLLAMA MODELLE" --menu "Wählen Sie eine Aktion:" 15 60 5 \
    "1" "Installierte Modelle anzeigen" \
    "2" "Modell installieren" \
    "3" "Modell deinstallieren" \
    "4" "Zurück zum Hauptmenü" 2> "$OLLAMA_CHOICE_FILE"
}

list_installed_models() {
    echo -e "${BLUE}Installierte Ollama Modelle:${NC}"
    if ! ollama list; then
        echo -e "${RED}Fehler: Installierte Modelle konnten nicht abgefragt werden.${NC}"
    fi
    read -r -p "Drücken Sie Enter, um fortzufahren..."
}

install_ollama_model() {
    local model_name

    rm -f "$MODEL_TO_INSTALL_FILE"
    dialog --clear --backtitle "Ollama Modell-Manager" \
    --inputbox "Geben Sie den Namen des zu installierenden Modells ein (z.B. llama3.2:1b, mistral, deepseek-coder):" 10 60 "" 2> "$MODEL_TO_INSTALL_FILE"

    if [ $? -ne 0 ] || [ ! -f "$MODEL_TO_INSTALL_FILE" ]; then
        return
    fi

    model_name="$(tr -d '\r' < "$MODEL_TO_INSTALL_FILE")"
    if [ -z "$model_name" ]; then
        echo -e "${YELLOW}Kein Modellname eingegeben.${NC}"
        read -r -p "Drücken Sie Enter, um fortzufahren..."
        return
    fi

    echo -e "${BLUE}Installiere Modell: ${model_name}...${NC}"
    if ollama pull "$model_name"; then
        echo -e "${GREEN}Modell ${model_name} erfolgreich installiert.${NC}"
    else
        echo -e "${RED}Fehler bei der Installation von Modell ${model_name}.${NC}"
    fi
    read -r -p "Drücken Sie Enter, um fortzufahren..."
}

uninstall_ollama_model() {
    local model_name

    rm -f "$MODEL_TO_UNINSTALL_FILE"
    dialog --clear --backtitle "Ollama Modell-Manager" \
    --inputbox "Geben Sie den Namen des zu deinstallierenden Modells ein:" 10 60 "" 2> "$MODEL_TO_UNINSTALL_FILE"

    if [ $? -ne 0 ] || [ ! -f "$MODEL_TO_UNINSTALL_FILE" ]; then
        return
    fi

    model_name="$(tr -d '\r' < "$MODEL_TO_UNINSTALL_FILE")"
    if [ -z "$model_name" ]; then
        echo -e "${YELLOW}Kein Modellname eingegeben.${NC}"
        read -r -p "Drücken Sie Enter, um fortzufahren..."
        return
    fi

    echo -e "${BLUE}Deinstalliere Modell: ${model_name}...${NC}"
    if ollama rm "$model_name"; then
        echo -e "${GREEN}Modell ${model_name} erfolgreich deinstalliert.${NC}"
    else
        echo -e "${RED}Fehler bei der Deinstallation von Modell ${model_name}.${NC}"
    fi
    read -r -p "Drücken Sie Enter, um fortzufahren..."
}

ensure_ollama_available
trap cleanup_temp_files EXIT

while true; do
    show_ollama_menu

    if [ $? -ne 0 ] || [ ! -f "$OLLAMA_CHOICE_FILE" ]; then
        break
    fi

    OLLAMA_CHOICE="$(tr -d '\r' < "$OLLAMA_CHOICE_FILE")"

    case "$OLLAMA_CHOICE" in
        1) list_installed_models ;;
        2) install_ollama_model ;;
        3) uninstall_ollama_model ;;
        4) break ;;
        *)
            echo -e "${RED}Ungültige Auswahl. Bitte versuchen Sie es erneut.${NC}"
            sleep 2
            ;;
    esac
done
