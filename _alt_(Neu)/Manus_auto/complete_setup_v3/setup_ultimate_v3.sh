#!/bin/bash
# ==============================================================================
# 🚀 ULTIMATIVE INTERAKTIVE INSTALLATIONSPLATTFORM V3
# Projekt: VPS-_Kubernate-_Ollama_OpenClaw_installation
# Fokus: pnpm, llama3.2:1b, Gemini-Fallback, Multi-VPS, gcali & RL
# ==============================================================================

# Farben & UI
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check dependencies
if ! command -v dialog >/dev/null 2>&1; then
    echo -e "${YELLOW}Installiere dialog für die Menüführung...${NC}"
    sudo apt update && sudo apt install -y dialog
fi

# Hauptmenü
show_main_menu() {
    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V3" \
    --title "HAUPTMENÜ" --menu "Wählen Sie Ihr Ziel-System:" 18 70 8 \
    "1" "Hybrid: Letsung MiniPC + Multi-VPS (Empfohlen)" \
    "2" "Standalone: Nur VPS (Cloud-Native)" \
    "3" "Profil: Programmierer-Setup (DeepSeek, Python, Git)" \
    "4" "Profil: Media & Musik (FFmpeg, Audio-AI, Alexa)" \
    "5" "Profil: KI-Forschung (OpenClaw RL, Gemini-1.5-Pro)" \
    "6" "Dokumentation & API-Key Guide" \
    "7" "System-Check & Port-Analyse" \
    "8" "Beenden" 2> /tmp/menu_choice
}

# Installations-Logik für Profile
install_profile() {
    PROFILE=$1
    case $PROFILE in
        "PROG")
            echo -e "${BLUE}Konfiguriere Programmierer-Setup...${NC}"
            # Spezifische Modelle & Tools
            ollama pull qwen2.5-coder:7b
            ;;
        "MEDIA")
            echo -e "${BLUE}Konfiguriere Media-Setup...${NC}"
            sudo apt install -y ffmpeg libsox-dev
            ;;
        "AI")
            echo -e "${BLUE}Konfiguriere KI-Forschungs-Setup (RL)...${NC}"
            # RL-Spezifische Installation
            ;;
    esac
}

# Hauptschleife
while true; do
    show_main_menu
    CHOICE=$(cat /tmp/menu_choice)
    
    case $CHOICE in
        1|2)
            # Basis-Installation (pnpm, Node, Python)
            echo -e "${BLUE}Starte Basis-Installation...${NC}"
            # [Hier folgen die detaillierten Aufrufe der Sub-Skripte]
            ./scripts/base_install.sh
            if [ "$CHOICE" == "1" ]; then
                ./scripts/hybrid_setup.sh
            else
                ./scripts/vps_standalone.sh
            fi
            read -p "Installation abgeschlossen. Drücken Sie Enter..."
            ;;
        3) install_profile "PROG";;
        4) install_profile "MEDIA";;
        5) install_profile "AI";;
        6) dialog --textbox ./docs/API_KEY_GUIDE.md 25 80;;
        7) ./scripts/port_check.sh;;
        8) exit 0;;
    esac
done
rm -f /tmp/menu_choice
