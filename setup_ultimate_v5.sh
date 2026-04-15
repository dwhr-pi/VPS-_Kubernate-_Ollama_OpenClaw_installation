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

# Funktion zum Installieren eines Profils
install_profile() {
    PROFILE_NAME=$1
    echo -e "${BLUE}Installiere Profil: ${PROFILE_NAME}...${NC}"
    "$INSTALL_DIR/scripts/profiles/${PROFILE_NAME}_install.sh"
    if [ $? -eq 0 ]; then
        echo "${PROFILE_NAME}" >> "$INSTALL_DIR/installed_profiles.txt"
        echo -e "${GREEN}Profil '${PROFILE_NAME}' erfolgreich installiert.${NC}"
    else
        echo -e "${RED}Fehler bei der Installation von Profil '${PROFILE_NAME}'.${NC}"
    fi
}

# Funktion zum Deinstallieren eines Profils
uninstall_profile() {
    PROFILE_NAME=$1
    echo -e "${BLUE}Deinstalliere Profil: ${PROFILE_NAME}...${NC}"
    "$INSTALL_DIR/scripts/profiles/${PROFILE_NAME}_uninstall.sh"
    if [ $? -eq 0 ]; then
        sed -i "/${PROFILE_NAME}/d" "$INSTALL_DIR/installed_profiles.txt"
        echo -e "${GREEN}Profil '${PROFILE_NAME}' erfolgreich deinstalliert.${NC}"
    else
        echo -e "${RED}Fehler bei der Deinstallation von Profil '${PROFILE_NAME}'.${NC}"
    fi
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
            "$INSTALL_DIR/scripts/install_local_only.sh"
            read -p "Standalone MiniPC-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        4)
            echo -e "${BLUE}Ruflo Installation & Management...${NC}"
            "$INSTALL_DIR/scripts/ruflo_install.sh"
            read -p "Ruflo-Aktion abgeschlossen. Drücken Sie Enter..."
            ;;
        5)
            # Profil-Management
            PROFILE_OPTIONS=(
                "Programmierer" "Tools für Entwicklung, Code-Generierung (DeepSeek Coder), Git-Integration." "off" \
                "Media_Musik" "Tools für Audio/Video (FFmpeg), Audio-AI, Alexa-Integration." "off" \
                "KI_Forschung" "Spezialisierte Bibliotheken für RL, erweiterte LLM-Modelle (Gemini-1.5-Pro)." "off" \
                "Texter_Werbung_Marketing" "Tools für Content-Generierung, SEO-Analyse, Social Media, Textproduktion." "off"
            )

            # Prüfen, welche Profile bereits installiert sind
            if [ -f "$INSTALL_DIR/installed_profiles.txt" ]; then
                while IFS= read -r profile_name; do
                    for i in "${!PROFILE_OPTIONS[@]}"; do
                        if [[ "${PROFILE_OPTIONS[$i]}" == "$profile_name" ]]; then
                            PROFILE_OPTIONS[$((i+2))]="on"
                        fi
                    done
                done < "$INSTALL_DIR/installed_profiles.txt"
            fi

            dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V5" \
            --title "PROFIL-MANAGEMENT" --checklist "Wählen Sie Profile zum Installieren/Deinstallieren:" 25 70 10 \
            "Programmierer" "Tools für Entwicklung, Code-Generierung (DeepSeek Coder), Git-Integration." "${PROFILE_OPTIONS[2]}" \
            "Media_Musik" "Tools für Audio/Video (FFmpeg), Audio-AI, Alexa-Integration." "${PROFILE_OPTIONS[5]}" \
            "KI_Forschung" "Spezialisierte Bibliotheken für RL, erweiterte LLM-Modelle (Gemini-1.5-Pro)." "${PROFILE_OPTIONS[8]}" \
            "Texter_Werbung_Marketing" "Tools für Content-Generierung, SEO-Analyse, Social Media, Textproduktion." "${PROFILE_OPTIONS[11]}" 2> /tmp/profile_selection

            SELECTED_PROFILES=$(cat /tmp/profile_selection)

            # Installierte Profile laden
            declare -A INSTALLED_PROFILES_MAP
            if [ -f "$INSTALL_DIR/installed_profiles.txt" ]; then
                while IFS= read -r profile_name; do
                    INSTALLED_PROFILES_MAP["$profile_name"]=1
                done < "$INSTALL_DIR/installed_profiles.txt"
            fi

            # Installation/Deinstallation basierend auf Auswahl
            for profile_key in "Programmierer" "Media_Musik" "KI_Forschung" "Texter_Werbung_Marketing"; do
                IS_SELECTED=false
                for selected_key in $SELECTED_PROFILES; do
                    if [[ "$profile_key" == "$selected_key" ]]; then
                        IS_SELECTED=true
                        break
                    fi
                done

                if $IS_SELECTED && [[ ! -v INSTALLED_PROFILES_MAP["$profile_key"] ]]; then
                    # Profil ausgewählt und nicht installiert -> Installieren
                    install_profile "$profile_key"
                elif ! $IS_SELECTED && [[ -v INSTALLED_PROFILES_MAP["$profile_key"] ]]; then
                    # Profil nicht ausgewählt und installiert -> Deinstallieren
                    uninstall_profile "$profile_key"
                fi
            done
            read -p "Profil-Management abgeschlossen. Drücken Sie Enter..."
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
rm -f /tmp/menu_choice /tmp/profile_selection
