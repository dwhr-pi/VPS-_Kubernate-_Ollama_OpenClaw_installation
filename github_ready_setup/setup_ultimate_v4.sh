#!/bin/bash
# ==============================================================================
# 🚀 ULTIMATIVE INTERAKTIVE INSTALLATIONSPLATTFORM V4
# Projekt: VPS-_Kubernate-_Ollama_OpenClaw_installation
# Fokus: pnpm, llama3.2:1b, Gemini-Fallback, Multi-VPS, gcali & RL
# ==============================================================================

# Farben & UI
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

# Check dependencies
if ! command -v dialog >/dev/null 2>&1; then
    echo -e "${YELLOW}Installiere dialog für die Menüführung...${NC}"
    sudo apt update && sudo apt install -y dialog
fi

# Hauptmenü
show_main_menu() {
    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V4" \
    --title "HAUPTMENÜ" --menu "Wählen Sie Ihr Ziel-System oder Profil:" 20 70 10 \
    "1" "Hybrid: Letsung MiniPC + Multi-VPS (Empfohlen)" \
    "2" "Standalone: Nur VPS (Cloud-Native)" \
    "3" "Profil: Programmierer-Setup (DeepSeek, Python, Git)" \
    "4" "Profil: Media & Musik (FFmpeg, Audio-AI, Alexa)" \
    "5" "Profil: KI-Forschung (OpenClaw RL, Gemini-1.5-Pro)" \
    "6" "Dokumentation & API-Key Guide" \
    "7" "System-Check & Port-Analyse" \
    "8" "OpenClaw starten (Dev-Modus)" \
    "9" "Home Assistant starten" \
    "10" "Beenden" 2> /tmp/menu_choice
}

# Installations-Logik für Profile
install_profile() {
    PROFILE=$1
    case $PROFILE in
        "PROG")
            echo -e "${BLUE}Konfiguriere Programmierer-Setup...${NC}"
            # Spezifische Modelle & Tools
            ollama pull qwen2.5-coder:7b
            # Weitere Programmierer-Tools hier installieren
            ;;
        "MEDIA")
            echo -e "${BLUE}Konfiguriere Media-Setup...${NC}"
            sudo apt install -y ffmpeg libsox-dev
            # Weitere Media-Tools hier installieren
            ;;
        "AI")
            echo -e "${BLUE}Konfiguriere KI-Forschungs-Setup (RL)...${NC}"
            # RL-Spezifische Installationen hier
            # z.B. Python RL Libraries
            ;;
    esac
}

# Hauptschleife
while true; do
    show_main_menu
    CHOICE=$(cat /tmp/menu_choice)
    
    case $CHOICE in
        1)
            echo -e "${BLUE}Starte Hybrid-Setup (Letsung MiniPC + Multi-VPS)...${NC}"
            ./scripts/base_install.sh
            ./scripts/hybrid_setup.sh
            read -p "Hybrid-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        2)
            echo -e "${BLUE}Starte Standalone VPS-Setup (Cloud-Native)...${NC}"
            ./scripts/base_install.sh
            ./scripts/vps_standalone.sh
            read -p "VPS-Standalone-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        3) install_profile "PROG";;
        4) install_profile "MEDIA";;
        5) install_profile "AI";;
        6)
            dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V4" \
            --title "Dokumentation & API-Key Guide" --textbox ./docs/API_KEY_GUIDE.md 25 80
            ;;
        7)
            ./scripts/port_check.sh
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
rm -f /tmp/menu_choice
