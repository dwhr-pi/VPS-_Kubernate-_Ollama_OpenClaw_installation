#!/bin/bash
# ==============================================================================
# 🚀 ULTIMATIVE INTERAKTIVE INSTALLATIONSPLATTFORM V5
# Projekt: VPS-_Kubernate-_Ollama_OpenClaw_installation
# Fokus: pnpm, llama3.2:1b, Gemini-Fallback, Multi-VPS, gcali & RL, Ruflo, Profile
# ==============================================================================

# Farben & UI
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

# Installationsverzeichnis (wird vom install.sh Skript gesetzt)
INSTALL_DIR="$(pwd)"

# Check dependencies
if ! command -v dialog >/dev/null 2>&1; then
    echo -e "${YELLOW}Installiere dialog für die Menüführung...${NC}"
    sudo apt update && sudo apt install -y dialog
fi

# Funktion zum Anzeigen des Hauptmenüs
show_main_menu() {
    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V5" \
    --title "HAUPTMENÜ" --menu "Wählen Sie Ihr Ziel-System oder Profil:" 25 70 15 \
    "1" "Hybrid: Letsung MiniPC + Multi-VPS (Empfohlen)" \
    "2" "Standalone: Nur VPS (Cloud-Native)" \
    "3" "Standalone: Nur MiniPC (Lokal)" \
    "4" "Ruflo: Installation & Management" \
    "5" "Profile: Installieren & Deinstallieren" \
    "6" "Dokumentation & API-Key Guide" \
    "7" "System-Check & Port-Analyse" \
    "8" "OpenClaw starten (Dev-Modus)" \
    "9" "Home Assistant starten" \
    "10" "Beenden" 2> /tmp/menu_choice
}

# Funktion zum Anzeigen des Profil-Menüs
show_profile_menu() {
    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V5" \
    --title "PROFIL-MANAGEMENT" --menu "Wählen Sie ein Profil oder eine Aktion:" 20 70 10 \
    "1" "Programmierer-Setup" \
    "2" "Media & Musik" \
    "3" "KI-Forschung" \
    "4" "Texter, Werbung & Marketing" \
    "5" "Alle installierten Profile anzeigen" \
    "6" "Profil deinstallieren" \
    "7" "Zurück zum Hauptmenü" 2> /tmp/profile_choice
}

# Installations-Logik für Profile
install_profile() {
    PROFILE_NAME=$1
    echo -e "${BLUE}Installiere Profil: ${PROFILE_NAME}...${NC}"
    # Hier würde die spezifische Installationslogik für jedes Profil stehen
    # Beispiel: ./scripts/profiles/${PROFILE_NAME}_install.sh
    echo -e "${GREEN}Profil '${PROFILE_NAME}' erfolgreich installiert (Platzhalter).${NC}"
    # Marker setzen, dass Profil installiert ist
    echo "${PROFILE_NAME}" >> "$INSTALL_DIR/installed_profiles.txt"
}

# Deinstallations-Logik für Profile
uninstall_profile() {
    PROFILE_NAME=$1
    echo -e "${BLUE}Deinstalliere Profil: ${PROFILE_NAME}...${NC}"
    # Hier würde die spezifische Deinstallationslogik für jedes Profil stehen
    # Beispiel: ./scripts/profiles/${PROFILE_NAME}_uninstall.sh
    sed -i "/${PROFILE_NAME}/d" "$INSTALL_DIR/installed_profiles.txt"
    echo -e "${GREEN}Profil '${PROFILE_NAME}' erfolgreich deinstalliert (Platzhalter).${NC}"
}

# Hauptschleife
while true; do
    show_main_menu
    CHOICE=$(cat /tmp/menu_choice)
    
    case $CHOICE in
        1)
            echo -e "${BLUE}Starte Hybrid-Setup (Letsung MiniPC + Multi-VPS)...${NC}"
            "$INSTALL_DIR/scripts/base_install.sh"
            "$INSTALL_DIR/scripts/hybrid_setup.sh"
            read -p "Hybrid-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        2)
            echo -e "${BLUE}Starte Standalone VPS-Setup (Cloud-Native)...${NC}"
            "$INSTALL_DIR/scripts/base_install.sh"
            "$INSTALL_DIR/scripts/vps_standalone.sh"
            read -p "VPS-Standalone-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        3)
            echo -e "${BLUE}Starte Standalone MiniPC-Setup (Lokal)...${NC}"
            "$INSTALL_DIR/scripts/base_install.sh"
            # Hier spezifische lokale Installationen, die nicht im Hybrid-Setup sind
            # z.B. Ruflo, wenn es nur lokal laufen soll
            "$INSTALL_DIR/scripts/install_local_only.sh" # Neues Skript für lokale Komponenten
            read -p "Standalone MiniPC-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        4)
            echo -e "${BLUE}Ruflo Installation & Management...${NC}"
            "$INSTALL_DIR/scripts/ruflo_install.sh"
            read -p "Ruflo-Aktion abgeschlossen. Drücken Sie Enter..."
            ;;
        5)
            while true; do
                show_profile_menu
                PROFILE_CHOICE=$(cat /tmp/profile_choice)
                case $PROFILE_CHOICE in
                    1) install_profile "Programmierer";; 
                    2) install_profile "Media_Musik";; 
                    3) install_profile "KI_Forschung";; 
                    4) install_profile "Texter_Werbung_Marketing";; 
                    5)
                        dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V5" \
                        --title "Installierte Profile" --textbox "$INSTALL_DIR/installed_profiles.txt" 20 60
                        ;;
                    6)
                        dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V5" \
                        --title "Profil deinstallieren" --inputbox "Welches Profil möchten Sie deinstallieren?" 10 60 "" 2> /tmp/profile_to_uninstall
                        PROFILE_TO_UNINSTALL=$(cat /tmp/profile_to_uninstall)
                        if [ -n "$PROFILE_TO_UNINSTALL" ]; then
                            uninstall_profile "$PROFILE_TO_UNINSTALL"
                        fi
                        ;;
                    7) break;;
                    *)
                        echo -e "${RED}Ungültige Auswahl. Bitte versuchen Sie es erneut.${NC}"
                        sleep 2
                        ;;
                esac
            done
            ;;
        6)
            dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V5" \
            --title "Dokumentation & API-Key Guide" --textbox "$INSTALL_DIR/docs/API_KEY_GUIDE.md" 25 80
            ;;
        7)
            "$INSTALL_DIR/scripts/port_check.sh"
            read -p "Port-Analyse abgeschlossen. Drücken Sie Enter..."
            ;;
        8)
            echo -e "${BLUE}Starte OpenClaw im Dev-Modus...${NC}"
            cd /opt/openclaw && pnpm dev
            ;;
        9)
            echo -e "${BLUE}Starte Home Assistant...${NC}"
            sudo systemctl start homeassistant@homeassistant
            ;;
        10)
            echo -e "${BLUE}Installation beendet. Auf Wiedersehen!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Ungültige Auswahl. Bitte versuchen Sie es erneut.${NC}"
            sleep 2
            ;;
    esac
done
rm -f /tmp/menu_choice /tmp/profile_choice /tmp/profile_to_uninstall
