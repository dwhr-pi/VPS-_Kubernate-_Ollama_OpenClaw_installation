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

# Check Ollama installation
if ! command -v ollama >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Ollama ist nicht installiert. Bitte installieren Sie Ollama zuerst.${NC}"
    exit 1
fi

# Funktion zum Anzeigen des Ollama Modell-Menüs
show_ollama_menu() {
    dialog --clear --backtitle "Ollama Modell-Manager" \
    --title "OLLAMA MODELLE" --menu "Wählen Sie eine Aktion:" 15 60 5 \
    "1" "Installierte Modelle anzeigen" \
    "2" "Modell installieren" \
    "3" "Modell deinstallieren" \
    "4" "Zurück zum Hauptmenü" 2> /tmp/ollama_choice
}

# Funktion zum Anzeigen installierter Modelle
list_installed_models() {
    echo -e "${BLUE}Installierte Ollama Modelle:${NC}"
    ollama list
    read -p "Drücken Sie Enter, um fortzufahren..."
}

# Funktion zum Installieren eines Modells
install_ollama_model() {
    dialog --clear --backtitle "Ollama Modell-Manager" \
    --inputbox "Geben Sie den Namen des zu installierenden Modells ein (z.B. llama3.2:1b, mistral, deepseek-coder):" 10 60 "" 2> /tmp/model_to_install
    MODEL_NAME=$(cat /tmp/model_to_install)
    if [ -n "$MODEL_NAME" ]; then
        echo -e "${BLUE}Installiere Modell: ${MODEL_NAME}...${NC}"
        ollama pull "$MODEL_NAME"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Modell ${MODEL_NAME} erfolgreich installiert.${NC}"
        else
            echo -e "${RED}Fehler bei der Installation von Modell ${MODEL_NAME}.${NC}"
        fi
    else
        echo -e "${YELLOW}Kein Modellname eingegeben.${NC}"
    fi
    read -p "Drücken Sie Enter, um fortzufahren..."
}

# Funktion zum Deinstallieren eines Modells
uninstall_ollama_model() {
    dialog --clear --backtitle "Ollama Modell-Manager" \
    --inputbox "Geben Sie den Namen des zu deinstallierenden Modells ein:" 10 60 "" 2> /tmp/model_to_uninstall
    MODEL_NAME=$(cat /tmp/model_to_uninstall)
    if [ -n "$MODEL_NAME" ]; then
        echo -e "${BLUE}Deinstalliere Modell: ${MODEL_NAME}...${NC}"
        ollama rm "$MODEL_NAME"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Modell ${MODEL_NAME} erfolgreich deinstalliert.${NC}"
        else
            echo -e "${RED}Fehler bei der Deinstallation von Modell ${MODEL_NAME}.${NC}"
        fi
    else
        echo -e "${YELLOW}Kein Modellname eingegeben.${NC}"
    fi
    read -p "Drücken Sie Enter, um fortzufahren..."
}

# Hauptschleife für Ollama Modell-Manager
while true; do
    show_ollama_menu
    OLLAMA_CHOICE=$(cat /tmp/ollama_choice)
    
    case $OLLAMA_CHOICE in
        1) list_installed_models;;
        2) install_ollama_model;;
        3) uninstall_ollama_model;;
        4) break;;
        *)
            echo -e "${RED}Ungültige Auswahl. Bitte versuchen Sie es erneut.${NC}"
            sleep 2
            ;;
    esac
done
rm -f /tmp/ollama_choice /tmp/model_to_install /tmp/model_to_uninstall
