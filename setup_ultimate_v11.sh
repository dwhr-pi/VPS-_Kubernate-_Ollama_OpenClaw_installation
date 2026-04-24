#!/bin/bash
#
# Skript: setup_ultimate_v11.sh
# Beschreibung: Dies ist das Hauptinstallationsskript für die ultimative KI-Infrastruktur.
# Es bietet eine interaktive Menüführung zur Installation, Deinstallation und Verwaltung verschiedener KI-Tools, Profile und Systemkomponenten.
# Das Skript unterstützt hybride Setups (MiniPC + Multi-VPS), Standalone-Installationen und bietet Funktionen wie Auto-Updates, Ollama-Modellverwaltung und OpenClaw-Konfiguration.
# Version: V11
#

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

# --- Funktionen für Profil-Management ---

# Profil-Definitionen mit Beschreibungen
declare -A PROFILES
PROFILES["Programmierer"]="Tools für Entwicklung, Code-Generierung (DeepSeek Coder), Git-Integration, Huginn, Clawhub CLI. Ideal für Entwickler und Automatisierungsexperten."
PROFILES["Media_Musik"]="Tools für Audio/Video (FFmpeg), Audio-AI, Alexa-Integration, Clawbake. Für Content Creator und Medienproduzenten."
PROFILES["KI_Forschung"]="Spezialisierte Bibliotheken für Reinforcement Learning (OpenClaw RL), erweiterte LLM-Modelle (Gemini-1.5-Pro), Flowise/LangFlow. Für KI-Wissenschaftler und Forscher."
PROFILES["Texter_Werbung_Marketing"]="Tools für Content-Generierung, SEO-Analyse, Social Media, Textproduktion, n8n, Activepieces. Optimiert für Marketingexperten und Texter, die ihre Inhalte mit KI verbessern möchten."
PROFILES["Rechtsberatung_Steuerrecht"]="Tools für Web-Search & Fetch, PDF-Reader/Document-Parser, Zotero. Für die Analyse von Rechtsdokumenten und Steuerrecht, unterstützt durch spezialisierte KI-Agenten."

# Funktion zum Installieren eines Profils
install_profile() {
    PROFILE_KEY=$1
    echo -e "${BLUE}Installiere Profil: ${PROFILE_KEY}...${NC}"
    "$INSTALL_DIR/scripts/profiles/${PROFILE_KEY}_install.sh"
    if [ $? -eq 0 ]; then
        echo "$PROFILE_KEY" >> "$INSTALL_DIR/installed_profiles.txt"
        echo -e "${GREEN}Profil \'$PROFILE_KEY\' erfolgreich installiert.${NC}"
    else
        echo -e "${RED}Fehler bei der Installation von Profil \'$PROFILE_KEY\'.${NC}"
    fi
}

# Funktion zum Deinstallieren eines Profils
uninstall_profile() {
    PROFILE_KEY=$1
    echo -e "${BLUE}Deinstalliere Profil: ${PROFILE_KEY}...${NC}"
    "$INSTALL_DIR/scripts/profiles/${PROFILE_KEY}_uninstall.sh"
    if [ $? -eq 0 ]; then
        sed -i "/${PROFILE_KEY}/d" "$INSTALL_DIR/installed_profiles.txt"
        echo -e "${GREEN}Profil \'$PROFILE_KEY\' erfolgreich deinstalliert.${NC}"
    else
        echo -e "${RED}Fehler bei der Deinstallation von Profil \'$PROFILE_KEY\'.${NC}"
    fi
}

# Funktion zum Anzeigen des Profil-Management-Menüs
show_profile_management_menu() {
    # Installierte Profile laden
    declare -A INSTALLED_PROFILES_MAP
    if [ -f "$INSTALL_DIR/installed_profiles.txt" ]; then
        while IFS= read -r profile_name; do
            INSTALLED_PROFILES_MAP["$profile_name"]=1
        done < "$INSTALL_DIR/installed_profiles.txt"
    fi

    PROFILE_CHECKLIST_OPTIONS=()
    for profile_key in "Programmierer" "Media_Musik" "KI_Forschung" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht"; do
        STATUS="off"
        if [[ -v INSTALLED_PROFILES_MAP["$profile_key"] ]]; then
            STATUS="on"
        fi
        PROFILE_CHECKLIST_OPTIONS+=("$profile_key" "${PROFILES[$profile_key]}" "$STATUS")
    done

    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V11" \
    --title "PROFIL-MANAGEMENT" --checklist "Wählen Sie Profile zum Installieren/Deinstallieren:" 25 70 10 \
    "${PROFILE_CHECKLIST_OPTIONS[@]}" 2> /tmp/profile_selection

    SELECTED_PROFILES=$(cat /tmp/profile_selection)

    # Installation/Deinstallation basierend auf Auswahl
    for profile_key in "Programmierer" "Media_Musik" "KI_Forschung" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht"; do
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
}

# --- Funktionen für Tool-Management ---

declare -A TOOLS
TOOLS["Ollama"]="Lokales LLM-Backend. Du kannst über den Ollama Modell-Manager spezifische Modelle installieren und verwalten."
TOOLS["OpenManus"]="KI-Agenten-Framework für automatisierte Aufgaben wie Web-Recherche und Datenanalyse."
TOOLS["OpenClaw"]="Fortschrittliches KI-Agenten-Framework mit Reinforcement Learning (RL) und Skill-Integration (z.B. gcali)."
TOOLS["Clawhub_CLI"]="Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten, dem zentralen Hub für KI-Agenten."
TOOLS["OpenClaw_RL"]="Reinforcement Learning Erweiterung für OpenClaw, ermöglicht dem Agenten das Lernen durch Interaktion."
TOOLS["Clawbake"]="Tool zur Automatisierung von Builds und Deployments, ideal für CI/CD-Pipelines."
TOOLS["n8n"]="Workflow-Automatisierungstool, das viele Apps und Dienste verbindet (Open-Source-Alternative zu Zapier)."
TOOLS["Activepieces"]="Open-Source-Alternative zu Zapier für Workflow-Automatisierung und Integrationen."
TOOLS["Flowise"]="Open-Source-UI für LLM-Anwendungen, basierend auf LangchainJS, zur visuellen Workflow-Erstellung."
TOOLS["LangFlow"]="UI für LangChain, um LLM-Anwendungen visuell zu erstellen und zu testen."
TOOLS["Pipedream"]="Serverless-Plattform zur Integration von APIs und Diensten (Self-Hosted-Option verfügbar)."
TOOLS["Huginn"]="Open-Source-Agentensystem, das Aktionen im Web automatisiert und Ereignisse überwacht."
TOOLS["Zenbot_trader"]="Plattform für automatisierten Krypto-Handel mit Backtesting, Sim-Trading und Live-Trading."
TOOLS["Kimi2"]="KI-Agent von Moonshot AI für intelligente Interaktionen und Aufgaben."
TOOLS["Clawhub"]="Zentraler Server für die Orchestrierung und Verwaltung von KI-Agenten und deren Interaktionen."
TOOLS["Huge_Facing"]="Integration von Hugging Face Modellen, entweder lokal über Ollama oder über die Hugging Face Inference API."

# Funktion zum Installieren eines Tools
install_tool() {
    TOOL_KEY=$1
    echo -e "${BLUE}Installiere Tool: ${TOOL_KEY}...${NC}"
    "$INSTALL_DIR/scripts/tools/${TOOL_KEY}_install.sh"
    if [ $? -eq 0 ]; then
        echo "$TOOL_KEY" >> "$INSTALL_DIR/installed_tools.txt"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich installiert.${NC}"
    else
        echo -e "${RED}Fehler bei der Installation von Tool \'$TOOL_KEY\'.${NC}"
    fi
}

# Funktion zum Deinstallieren eines Tools
uninstall_tool() {
    TOOL_KEY=$1
    echo -e "${BLUE}Deinstalliere Tool: ${TOOL_KEY}...${NC}"
    "$INSTALL_DIR/scripts/tools/${TOOL_KEY}_uninstall.sh"
    if [ $? -eq 0 ]; then
        sed -i "/${TOOL_KEY}/d" "$INSTALL_DIR/installed_tools.txt"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich deinstalliert.${NC}"
    else
        echo -e "${RED}Fehler bei der Deinstallation von Tool \'$TOOL_KEY\'.${NC}"
    fi
}

# Funktion zum Anzeigen des Tool-Management-Menüs
show_tool_management_menu() {
    # Installierte Tools laden
    declare -A INSTALLED_TOOLS_MAP
    if [ -f "$INSTALL_DIR/installed_tools.txt" ]; then
        while IFS= read -r tool_name; do
            INSTALLED_TOOLS_MAP["$tool_name"]=1
        done < "$INSTALL_DIR/installed_tools.txt"
    fi

    TOOL_CHECKLIST_OPTIONS=()
    for tool_key in "Ollama" "OpenManus" "OpenClaw" "Clawhub_CLI" "OpenClaw_RL" "Clawbake" "n8n" "Activepieces" "Flowise" "LangFlow" "Pipedream" "Huginn" "Zenbot_trader" "Kimi2" "Clawhub" "Huge_Facing"; do
        STATUS="off"
        if [[ -v INSTALLED_TOOLS_MAP["$tool_key"] ]]; then
            STATUS="on"
        fi
        TOOL_CHECKLIST_OPTIONS+=("$tool_key" "${TOOLS[$tool_key]}" "$STATUS")
    done

    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V11" \
    --title "TOOL-MANAGEMENT" --checklist "Wählen Sie Tools zum Installieren/Deinstallieren:" 25 70 15 \
    "${TOOL_CHECKLIST_OPTIONS[@]}" 2> /tmp/tool_selection

    SELECTED_TOOLS=$(cat /tmp/tool_selection)

    # Installation/Deinstallation basierend auf Auswahl
    for tool_key in "Ollama" "OpenManus" "OpenClaw" "Clawhub_CLI" "OpenClaw_RL" "Clawbake" "n8n" "Activepieces" "Flowise" "LangFlow" "Pipedream" "Huginn" "Zenbot_trader" "Kimi2" "Clawhub" "Huge_Facing"; do
        IS_SELECTED=false
        for selected_key in $SELECTED_TOOLS; do
            if [[ "$tool_key" == "$selected_key" ]]; then
                IS_SELECTED=true
                break
            fi
        done

        if $IS_SELECTED && [[ ! -v INSTALLED_TOOLS_MAP["$tool_key"] ]]; then
            # Tool ausgewählt und nicht installiert -> Installieren
            install_tool "$tool_key"
        elif ! $IS_SELECTED && [[ -v INSTALLED_TOOLS_MAP["$tool_key"] ]]; then
            # Tool nicht ausgewählt und installiert -> Deinstallieren
            uninstall_tool "$tool_key"
        fi
    done
    read -p "Tool-Management abgeschlossen. Drücken Sie Enter..."
}

# --- Hauptmenü --- 

show_main_menu() {
    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V11" \
    --title "HAUPTMENÜ" --menu "Wählen Sie Ihr Ziel-System oder eine Aktion:" 25 70 16 \
    "1" "System-Update (OS & pnpm)" \
    "2" "Ollama Modell-Manager" \
    "3" "OpenClaw Konfiguration (.env & config.json)" \
    "4" "Hybrid: Letsung MiniPC + Multi-VPS (Empfohlen)" \
    "5" "Standalone: Nur VPS (Cloud-Native)" \
    "6" "Standalone: Nur MiniPC (Lokal)" \
    "7" "Ruflo: Installation & Management" \
    "8" "Tools: Installieren & Deinstallieren" \
    "9" "Profile: Installieren & Deinstallieren" \
    "10" "Dokumentation & API-Key Guide" \
    "11" "System-Check & Port-Analyse" \
    "12" "OpenClaw starten (Dev-Modus)" \
    "13" "Home Assistant starten" \
    "14" "Beenden" 2> /tmp/menu_choice
}

# Hauptschleife
while true; do
    show_main_menu
    CHOICE=$(cat /tmp/menu_choice)
    
    case $CHOICE in
        1)
            "$INSTALL_DIR/scripts/auto_update.sh"
            read -p "System-Update abgeschlossen. Drücken Sie Enter..."
            ;;
        2)
            "$INSTALL_DIR/scripts/ollama_model_manager.sh"
            read -p "Ollama Modell-Management abgeschlossen. Drücken Sie Enter..."
            ;;
        3)
            "$INSTALL_DIR/scripts/openclaw_config_manager.sh"
            read -p "OpenClaw Konfiguration abgeschlossen. Drücken Sie Enter..."
            ;;
        4)
            echo -e "${BLUE}Starte Hybrid-Setup (Letsung MiniPC + Multi-VPS)...${NC}"
            "$INSTALL_DIR/scripts/base_install.sh"
            "$INSTALL_DIR/scripts/hybrid_setup.sh"
            read -p "Hybrid-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        5)
            echo -e "${BLUE}Starte Standalone VPS-Setup (Cloud-Native)...${NC}"
            "$INSTALL_DIR/scripts/base_install.sh"
            "$INSTALL_DIR/scripts/vps_standalone.sh"
            read -p "VPS-Standalone-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        6)
            echo -e "${BLUE}Starte Standalone MiniPC-Setup (Lokal)...${NC}"
            "$INSTALL_DIR/scripts/base_install.sh"
            "$INSTALL_DIR/scripts/install_local_only.sh"
            read -p "Standalone MiniPC-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        7)
            echo -e "${BLUE}Ruflo Installation & Management...${NC}"
            "$INSTALL_DIR/scripts/ruflo_install.sh"
            read -p "Ruflo-Aktion abgeschlossen. Drücken Sie Enter..."
            ;;
        8)
            show_tool_management_menu
            ;;
        9)
            show_profile_management_menu
            ;;
        10)
            dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V11" \
            --title "Dokumentation & API-Key Guide" --textbox "$INSTALL_DIR/docs/API_KEY_GUIDE.md" 25 80
            ;;
        11)
            "$INSTALL_DIR/scripts/port_check.sh"
            read -p "Port-Analyse abgeschlossen. Drücken Sie Enter..."
            ;;
        12)
            echo -e "${BLUE}Starte OpenClaw im Dev-Modus...${NC}"
            cd /opt/openclaw && pnpm dev
            ;;
        13)
            echo -e "${BLUE}Starte Home Assistant...${NC}"
            sudo systemctl start homeassistant@homeassistant
            ;;
        14)
            echo -e "${BLUE}Installation beendet. Auf Wiedersehen!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Ungültige Auswahl. Bitte versuchen Sie es erneut.${NC}"
            sleep 2
            ;;
    esac
done
rm -f /tmp/menu_choice /tmp/profile_selection /tmp/tool_selection
