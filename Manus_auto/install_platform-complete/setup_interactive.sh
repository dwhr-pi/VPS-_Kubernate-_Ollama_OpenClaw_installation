#!/bin/bash
# ==============================================================================
# INTERAKTIVE INSTALLATIONSPLATTFORM FÜR KI- & HOME-SETUP
# Dieses Skript bietet eine Menüführung zur Installation der Komponenten
# auf WSL2 (Letsung MiniPC) oder einem VPS (Kubernetes).
# ==============================================================================

# Farben für die Ausgabe
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
NC=\033[0m

# Funktion zum Prüfen und Installieren von dialog/whiptail
check_dialog_whiptail() {
    if command -v dialog >/dev/null 2>&1; then
        DIALOG_CMD="dialog"
    elif command -v whiptail >/dev/null 2>&1; then
        DIALOG_CMD="whiptail"
    else
        echo -e "${RED}dialog oder whiptail nicht gefunden. Versuche zu installieren...${NC}"
        sudo apt update && sudo apt install -y dialog
        if command -v dialog >/dev/null 2>&1; then
            DIALOG_CMD="dialog"
        else
            echo -e "${RED}Konnte dialog/whiptail nicht installieren. Bitte manuell installieren: sudo apt install dialog${NC}"
            exit 1
        fi
    fi
}

# Hauptmenü anzeigen
show_main_menu() {
    ${DIALOG_CMD} --clear --backtitle "Interaktive Installationsplattform" \
    --title "Hauptmenü" --menu "Wählen Sie eine Installationsoption:" 15 60 4 \
    "1" "WSL2 (Letsung MiniPC) Setup"
    "2" "VPS-only (Kubernetes) Setup"
    "3" "Dokumentation anzeigen"
    "4" "Beenden"
    2> /tmp/menu_choice
}

# Hauptlogik
check_dialog_whiptail

while true; do
    show_main_menu
    CHOICE=$(cat /tmp/menu_choice)
    
    case $CHOICE in
        1)
            echo -e "${BLUE}Starte WSL2 (Letsung MiniPC) Setup...${NC}"
            ./scripts/install_local_wsl2.sh
            echo -e "${GREEN}WSL2 Setup abgeschlossen!${NC}"
            read -p "Drücken Sie Enter, um fortzufahren..."
            ;;
        2)
            echo -e "${BLUE}Starte VPS-only (Kubernetes) Setup...${NC}"
            ./scripts/install_vps_k8s.sh
            echo -e "${GREEN}VPS Setup abgeschlossen!${NC}"
            read -p "Drücken Sie Enter, um fortzufahren..."
            ;;
        3)
            ${DIALOG_CMD} --clear --backtitle "Interaktive Installationsplattform" \
            --title "Dokumentation" --textbox ./docs/setup_guide.md 25 80
            ;;
        4)
            echo -e "${BLUE}Installation beendet. Auf Wiedersehen!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Ungültige Auswahl. Bitte versuchen Sie es erneut.${NC}"
            sleep 2
            ;;
    esac
done

rm -f /tmp/menu_choice
