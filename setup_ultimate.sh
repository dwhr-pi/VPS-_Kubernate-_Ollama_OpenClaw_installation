#!/bin/bash
#
# Skript: setup_ultimate.sh
# Beschreibung: Dies ist das Hauptinstallationsskript für die ultimative KI-Infrastruktur.
# Es bietet eine interaktive Menüführung zur Installation, Deinstallation und Verwaltung verschiedener KI-Tools, Profile und Systemkomponenten.
# Das Skript unterstützt hybride Setups (MiniPC + Multi-VPS), Standalone-Installationen und bietet Funktionen wie Auto-Updates, Ollama-Modellverwaltung und OpenClaw-Konfiguration.
# Version: V11
#

# Farben & UI
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Installationsverzeichnis
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_bash_script() {
    local script_path="$1"

    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Fehler: Skript nicht gefunden: $script_path${NC}"
        return 1
    fi

    bash "$script_path"
}

append_unique_line() {
    local file_path="$1"
    local value="$2"

    touch "$file_path"
    if ! grep -Fxq "$value" "$file_path"; then
        echo "$value" >> "$file_path"
    fi
}

remove_exact_line() {
    local file_path="$1"
    local value="$2"

    [ -f "$file_path" ] || return 0
    sed -i "\|^${value}\$|d" "$file_path"
}

is_allowed_value() {
    local candidate="$1"
    shift
    local allowed

    for allowed in "$@"; do
        if [ "$candidate" = "$allowed" ]; then
            return 0
        fi
    done

    return 1
}

normalize_status_file() {
    local file_path="$1"
    shift
    local allowed_values=("$@")
    local tmp_file
    local backup_file
    local entry_name
    local cleaned_name
    local has_changes=0
    declare -A seen_values

    mkdir -p "$(dirname "$file_path")"
    touch "$file_path"
    tmp_file="$(mktemp)"

    while IFS= read -r entry_name || [ -n "$entry_name" ]; do
        cleaned_name="${entry_name%$'\r'}"
        cleaned_name="${cleaned_name//\"/}"

        if [ "$cleaned_name" != "$entry_name" ]; then
            has_changes=1
        fi

        if [ -z "$cleaned_name" ]; then
            [ -n "$entry_name" ] && has_changes=1
            continue
        fi

        if ! is_allowed_value "$cleaned_name" "${allowed_values[@]}"; then
            has_changes=1
            continue
        fi

        if [[ -n "${seen_values[$cleaned_name]:-}" ]]; then
            has_changes=1
            continue
        fi

        seen_values["$cleaned_name"]=1
        printf '%s\n' "$cleaned_name" >> "$tmp_file"
    done < "$file_path"

    if ! cmp -s "$file_path" "$tmp_file"; then
        has_changes=1
    fi

    if [ "$has_changes" -eq 1 ]; then
        backup_file="${file_path}.bak.$(date +%Y%m%d_%H%M%S)"
        cp "$file_path" "$backup_file" 2>/dev/null || true
        mv "$tmp_file" "$file_path"
        echo -e "${YELLOW}Hinweis: Statusdatei $(basename "$file_path") wurde bereinigt. Sicherung: $backup_file${NC}"
    else
        rm -f "$tmp_file"
    fi
}

load_installed_map() {
    local file_path="$1"
    local map_name="$2"
    local entry_name

    [ -f "$file_path" ] || return 0

    while IFS= read -r entry_name || [ -n "$entry_name" ]; do
        entry_name="${entry_name%$'\r'}"
        entry_name="${entry_name//\"/}"
        [ -n "$entry_name" ] || continue
        eval "$map_name[\"\$entry_name\"]=1"
    done < "$file_path"
}

selection_contains() {
    local needle="$1"
    shift
    local item

    for item in "$@"; do
        if [ "$item" = "$needle" ]; then
            return 0
        fi
    done

    return 1
}

is_base_install_ready() {
    command -v node >/dev/null 2>&1 || return 1
    command -v pnpm >/dev/null 2>&1 || return 1
    command -v ollama >/dev/null 2>&1 || return 1
    [ -d /opt/openclaw ] || return 1
    [ -f /opt/openclaw/package.json ] || return 1
    [ -d /opt/openclaw/node_modules ] || return 1
    return 0
}

run_base_install_if_needed() {
    if is_base_install_ready; then
        echo -e "${GREEN}Basis-Installation bereits vorhanden. Überspringe erneuten OpenClaw-Build.${NC}"
        echo -e "${YELLOW}Hinweis: Falls Sie bewusst neu bauen möchten, führen Sie scripts/base_install.sh manuell aus.${NC}"
        return 0
    fi

    echo -e "${BLUE}Starte Basis-Installation. Der OpenClaw-Build kann mehrere Minuten dauern.${NC}"
    run_bash_script "$INSTALL_DIR/scripts/base_install.sh"
}

# Check dependencies
if ! command -v dialog >/dev/null 2>&1; then
    echo -e "${YELLOW}Installiere dialog für die Menüführung...${NC}"
    sudo apt update && sudo apt install -y dialog
fi

# --- Funktionen für Profil-Management ---

# Profil-Definitionen mit Beschreibungen
declare -A PROFILES
PROFILE_KEYS=("Programmierer" "Media_Musik" "KI_Forschung" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht")
PROFILES["Programmierer"]="Tools für Entwicklung, Code-Generierung (DeepSeek Coder), Git-Integration, Huginn, Clawhub CLI. Ideal für Entwickler und Automatisierungsexperten."
PROFILES["Media_Musik"]="Tools für Audio/Video (FFmpeg), Audio-AI, Alexa-Integration, Clawbake. Für Content Creator und Medienproduzenten."
PROFILES["KI_Forschung"]="Spezialisierte Bibliotheken für Reinforcement Learning (OpenClaw RL), erweiterte LLM-Modelle (Gemini-1.5-Pro), Flowise/LangFlow. Für KI-Wissenschaftler und Forscher."
PROFILES["Texter_Werbung_Marketing"]="Tools für Content-Generierung, SEO-Analyse, Social Media, Textproduktion, n8n, Activepieces. Optimiert für Marketingexperten und Texter, die ihre Inhalte mit KI verbessern möchten."
PROFILES["Rechtsberatung_Steuerrecht"]="Tools für Web-Search & Fetch, PDF-Reader/Document-Parser, Zotero. Für die Analyse von Rechtsdokumenten und Steuerrecht, unterstützt durch spezialisierte KI-Agenten."

# Funktion zum Installieren eines Profils
install_profile() {
    local PROFILE_KEY="$1"
    echo -e "${BLUE}Installiere Profil: ${PROFILE_KEY}...${NC}"
    run_bash_script "$INSTALL_DIR/scripts/profiles/${PROFILE_KEY}_install.sh"
    if [ $? -eq 0 ]; then
        append_unique_line "$INSTALL_DIR/installed_profiles.txt" "$PROFILE_KEY"
        echo -e "${GREEN}Profil \'$PROFILE_KEY\' erfolgreich installiert.${NC}"
    else
        echo -e "${RED}Fehler bei der Installation von Profil \'$PROFILE_KEY\'.${NC}"
    fi
}

# Funktion zum Deinstallieren eines Profils
uninstall_profile() {
    local PROFILE_KEY="$1"
    echo -e "${BLUE}Deinstalliere Profil: ${PROFILE_KEY}...${NC}"
    run_bash_script "$INSTALL_DIR/scripts/profiles/${PROFILE_KEY}_uninstall.sh"
    if [ $? -eq 0 ]; then
        remove_exact_line "$INSTALL_DIR/installed_profiles.txt" "$PROFILE_KEY"
        echo -e "${GREEN}Profil \'$PROFILE_KEY\' erfolgreich deinstalliert.${NC}"
    else
        echo -e "${RED}Fehler bei der Deinstallation von Profil \'$PROFILE_KEY\'.${NC}"
    fi
}

# Funktion zum Anzeigen des Profil-Management-Menüs
show_profile_management_menu() {
    normalize_status_file "$INSTALL_DIR/installed_profiles.txt" "${PROFILE_KEYS[@]}"

    # Installierte Profile laden
    declare -A INSTALLED_PROFILES_MAP
    load_installed_map "$INSTALL_DIR/installed_profiles.txt" INSTALLED_PROFILES_MAP

    PROFILE_CHECKLIST_OPTIONS=()
    for profile_key in "${PROFILE_KEYS[@]}"; do
        STATUS="off"
        if [[ -v INSTALLED_PROFILES_MAP["$profile_key"] ]]; then
            STATUS="on"
        fi
        PROFILE_CHECKLIST_OPTIONS+=("$profile_key" "${PROFILES[$profile_key]}" "$STATUS")
    done

    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V11" \
    --title "PROFIL-MANAGEMENT" --checklist "Wählen Sie Profile zum Installieren/Deinstallieren:" 25 70 10 \
    "${PROFILE_CHECKLIST_OPTIONS[@]}" 2> /tmp/profile_selection

    if [ $? -ne 0 ]; then
        return 0
    fi

    mapfile -t SELECTED_PROFILES_ARRAY < <(tr ' ' '\n' < /tmp/profile_selection | tr -d '"' | sed '/^$/d')

    # Installation/Deinstallation basierend auf Auswahl
    for profile_key in "${PROFILE_KEYS[@]}"; do
        if selection_contains "$profile_key" "${SELECTED_PROFILES_ARRAY[@]}" && [[ ! -v INSTALLED_PROFILES_MAP["$profile_key"] ]]; then
            # Profil ausgewählt und nicht installiert -> Installieren
            install_profile "$profile_key"
        elif ! selection_contains "$profile_key" "${SELECTED_PROFILES_ARRAY[@]}" && [[ -v INSTALLED_PROFILES_MAP["$profile_key"] ]]; then
            # Profil nicht ausgewählt und installiert -> Deinstallieren
            uninstall_profile "$profile_key"
        fi
    done
    read -p "Profil-Management abgeschlossen. Drücken Sie Enter..."
}

# --- Funktionen für Tool-Management ---

declare -A TOOLS
declare -A TOOL_SCRIPT_NAMES
TOOL_KEYS=("Ollama" "OpenManus" "OpenClaw" "Clawhub_CLI" "OpenClaw_RL" "Clawbake" "n8n" "Activepieces" "Flowise" "LangFlow" "AutoGPT" "Pipedream" "Huginn" "FFmpeg" "LangGraph" "CrewAI" "AutoGen" "Playwright" "ChromaDB" "LangChain" "LlamaIndex" "MLflow" "Whisper" "librosa" "pydub" "Demucs" "Zenbot_trader" "Kimi2" "Clawhub" "Huge_Facing" "Zotero")
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
TOOLS["AutoGPT"]="Agenten-Plattform von Significant Gravitas zur Erstellung, Ausführung und Verwaltung komplexer KI-Workflows."
TOOLS["Pipedream"]="Serverless-Plattform zur Integration von APIs und Diensten (Self-Hosted-Option verfügbar)."
TOOLS["Huginn"]="Open-Source-Agentensystem, das Aktionen im Web automatisiert und Ereignisse überwacht."
TOOLS["FFmpeg"]="CLI-Werkzeug für Audio- und Videoverarbeitung, nützlich für Medienprofile und Konvertierungs-Workflows."
TOOLS["LangGraph"]="Graph-basierte Workflow-Orchestrierung für mehrstufige Agentensysteme."
TOOLS["CrewAI"]="Multi-Agent Framework für spezialisierte Rollen und abgestimmte Team-Workflows."
TOOLS["AutoGen"]="Microsoft AutoGen für dialogbasierte Multi-Agent Koordination."
TOOLS["Playwright"]="Browser-Automatisierung für Tests, Scraping und UI-Workflows."
TOOLS["ChromaDB"]="Lokale Vector-Datenbank für RAG, Prompt-Memory und Wissensspeicher."
TOOLS["LangChain"]="RAG-, Tool-Use- und Agenten-Bausteine für OpenClaw-nahe Pipelines."
TOOLS["LlamaIndex"]="Dokumenten-Indexierung und Retrieval für Research- und Legal-Workflows."
TOOLS["MLflow"]="Experiment-Tracking für Forschungs- und Modellvergleiche."
TOOLS["Whisper"]="Lokale Speech-to-Text-Pipeline für Audio- und Forschungsdaten."
TOOLS["librosa"]="Audioanalyse für BPM, Key, Spektren und Energielevel."
TOOLS["pydub"]="Einfache Audio-Manipulation für Schnitt, Fades und Export."
TOOLS["Demucs"]="Stem-Separation für Musik- und Remix-Workflows."
TOOLS["Zenbot_trader"]="Plattform für automatisierten Krypto-Handel mit Backtesting, Sim-Trading und Live-Trading."
TOOLS["Kimi2"]="KI-Agent von Moonshot AI für intelligente Interaktionen und Aufgaben."
TOOLS["Clawhub"]="Zentraler Server für die Orchestrierung und Verwaltung von KI-Agenten und deren Interaktionen."
TOOLS["Huge_Facing"]="Integration von Hugging Face Modellen, entweder lokal über Ollama oder über die Hugging Face Inference API."
TOOLS["Zotero"]="Literatur- und Quellenverwaltung für Recherche- und Dokumentations-Workflows."
TOOL_SCRIPT_NAMES["Ollama"]="ollama"
TOOL_SCRIPT_NAMES["OpenManus"]="openmanus"
TOOL_SCRIPT_NAMES["OpenClaw"]="openclaw"
TOOL_SCRIPT_NAMES["Clawhub_CLI"]="clawhub_cli"
TOOL_SCRIPT_NAMES["OpenClaw_RL"]="openclaw_rl"
TOOL_SCRIPT_NAMES["Clawbake"]="clawbake"
TOOL_SCRIPT_NAMES["n8n"]="n8n"
TOOL_SCRIPT_NAMES["Activepieces"]="activepieces"
TOOL_SCRIPT_NAMES["Flowise"]="flowise"
TOOL_SCRIPT_NAMES["LangFlow"]="langflow"
TOOL_SCRIPT_NAMES["AutoGPT"]="autogpt"
TOOL_SCRIPT_NAMES["Pipedream"]="pipedream"
TOOL_SCRIPT_NAMES["Huginn"]="huginn"
TOOL_SCRIPT_NAMES["FFmpeg"]="ffmpeg"
TOOL_SCRIPT_NAMES["LangGraph"]="langgraph"
TOOL_SCRIPT_NAMES["CrewAI"]="crewai"
TOOL_SCRIPT_NAMES["AutoGen"]="autogen"
TOOL_SCRIPT_NAMES["Playwright"]="playwright"
TOOL_SCRIPT_NAMES["ChromaDB"]="chromadb"
TOOL_SCRIPT_NAMES["LangChain"]="langchain"
TOOL_SCRIPT_NAMES["LlamaIndex"]="llamaindex"
TOOL_SCRIPT_NAMES["MLflow"]="mlflow"
TOOL_SCRIPT_NAMES["Whisper"]="whisper"
TOOL_SCRIPT_NAMES["librosa"]="librosa"
TOOL_SCRIPT_NAMES["pydub"]="pydub"
TOOL_SCRIPT_NAMES["Demucs"]="demucs"
TOOL_SCRIPT_NAMES["Zenbot_trader"]="zenbot_trader"
TOOL_SCRIPT_NAMES["Kimi2"]="kimi2"
TOOL_SCRIPT_NAMES["Clawhub"]="clawhub"
TOOL_SCRIPT_NAMES["Huge_Facing"]="huge_facing"
TOOL_SCRIPT_NAMES["Zotero"]="zotero"

run_tool_script() {
    local tool_key="$1"
    local action="$2"
    local script_name="${TOOL_SCRIPT_NAMES[$tool_key]}"

    if [ -z "$script_name" ]; then
        echo -e "${RED}Fehler: Kein Skript-Mapping für Tool '$tool_key' gefunden.${NC}"
        return 1
    fi

    run_bash_script "$INSTALL_DIR/scripts/tools/${script_name}_${action}.sh"
}

# Funktion zum Installieren eines Tools
install_tool() {
    local TOOL_KEY="$1"
    echo -e "${BLUE}Installiere Tool: ${TOOL_KEY}...${NC}"
    run_tool_script "$TOOL_KEY" "install"
    if [ $? -eq 0 ]; then
        append_unique_line "$INSTALL_DIR/installed_tools.txt" "$TOOL_KEY"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich installiert.${NC}"
    else
        echo -e "${RED}Fehler bei der Installation von Tool \'$TOOL_KEY\'.${NC}"
    fi
}

# Funktion zum Deinstallieren eines Tools
uninstall_tool() {
    local TOOL_KEY="$1"
    echo -e "${BLUE}Deinstalliere Tool: ${TOOL_KEY}...${NC}"
    run_tool_script "$TOOL_KEY" "uninstall"
    if [ $? -eq 0 ]; then
        remove_exact_line "$INSTALL_DIR/installed_tools.txt" "$TOOL_KEY"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich deinstalliert.${NC}"
    else
        echo -e "${RED}Fehler bei der Deinstallation von Tool \'$TOOL_KEY\'.${NC}"
    fi
}

# Funktion zum Anzeigen des Tool-Management-Menüs
show_tool_management_menu() {
    normalize_status_file "$INSTALL_DIR/installed_tools.txt" "${TOOL_KEYS[@]}"

    # Installierte Tools laden
    declare -A INSTALLED_TOOLS_MAP
    load_installed_map "$INSTALL_DIR/installed_tools.txt" INSTALLED_TOOLS_MAP

    TOOL_CHECKLIST_OPTIONS=()
    for tool_key in "${TOOL_KEYS[@]}"; do
        STATUS="off"
        if [[ -v INSTALLED_TOOLS_MAP["$tool_key"] ]]; then
            STATUS="on"
        fi
        TOOL_CHECKLIST_OPTIONS+=("$tool_key" "${TOOLS[$tool_key]}" "$STATUS")
    done

    dialog --clear --backtitle "OpenClaw & AI Infrastructure - Ultimate Setup V11" \
    --title "TOOL-MANAGEMENT" --checklist "Wählen Sie Tools zum Installieren/Deinstallieren:" 25 70 15 \
    "${TOOL_CHECKLIST_OPTIONS[@]}" 2> /tmp/tool_selection

    if [ $? -ne 0 ]; then
        return 0
    fi

    mapfile -t SELECTED_TOOLS_ARRAY < <(tr ' ' '\n' < /tmp/tool_selection | tr -d '"' | sed '/^$/d')

    # Installation/Deinstallation basierend auf Auswahl
    for tool_key in "${TOOL_KEYS[@]}"; do
        if selection_contains "$tool_key" "${SELECTED_TOOLS_ARRAY[@]}" && [[ ! -v INSTALLED_TOOLS_MAP["$tool_key"] ]]; then
            # Tool ausgewählt und nicht installiert -> Installieren
            install_tool "$tool_key"
        elif ! selection_contains "$tool_key" "${SELECTED_TOOLS_ARRAY[@]}" && [[ -v INSTALLED_TOOLS_MAP["$tool_key"] ]]; then
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
            run_bash_script "$INSTALL_DIR/scripts/auto_update.sh"
            read -p "System-Update abgeschlossen. Drücken Sie Enter..."
            ;;
        2)
            run_bash_script "$INSTALL_DIR/scripts/ollama_model_manager.sh"
            read -p "Ollama Modell-Management abgeschlossen. Drücken Sie Enter..."
            ;;
        3)
            run_bash_script "$INSTALL_DIR/scripts/openclaw_config_manager.sh"
            read -p "OpenClaw Konfiguration abgeschlossen. Drücken Sie Enter..."
            ;;
        4)
            echo -e "${BLUE}Starte Hybrid-Setup (Letsung MiniPC + Multi-VPS)...${NC}"
            if run_base_install_if_needed; then
                run_bash_script "$INSTALL_DIR/scripts/hybrid_setup.sh"
            else
                echo -e "${RED}Hybrid-Setup abgebrochen, weil die Basis-Installation fehlgeschlagen ist.${NC}"
            fi
            read -p "Hybrid-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        5)
            echo -e "${BLUE}Starte Standalone VPS-Setup (Cloud-Native)...${NC}"
            if run_base_install_if_needed; then
                run_bash_script "$INSTALL_DIR/scripts/vps_standalone.sh"
            else
                echo -e "${RED}VPS-Standalone-Setup abgebrochen, weil die Basis-Installation fehlgeschlagen ist.${NC}"
            fi
            read -p "VPS-Standalone-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        6)
            echo -e "${BLUE}Starte Standalone MiniPC-Setup (Lokal)...${NC}"
            if run_base_install_if_needed; then
                run_bash_script "$INSTALL_DIR/scripts/install_local_only.sh"
            else
                echo -e "${RED}Standalone MiniPC-Setup abgebrochen, weil die Basis-Installation fehlgeschlagen ist.${NC}"
            fi
            read -p "Standalone MiniPC-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        7)
            echo -e "${BLUE}Ruflo Installation & Management...${NC}"
            run_bash_script "$INSTALL_DIR/scripts/ruflo_install.sh"
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
            run_bash_script "$INSTALL_DIR/scripts/port_check.sh"
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
