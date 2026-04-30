#!/bin/bash
#
# Skript: setup_ultimate.sh
# Beschreibung: Dies ist das Hauptinstallationsskript für die ultimative KI-Infrastruktur.
# Es bietet eine interaktive Menüführung zur Installation, Deinstallation und Verwaltung verschiedener KI-Tools, Profile und Systemkomponenten.
# Das Skript unterstützt hybride Setups (MiniPC + Multi-VPS), Standalone-Installationen und bietet Funktionen wie Auto-Updates, Ollama-Modellverwaltung und OpenClaw-Konfiguration.
# Version: V11.13
#

# Farben & UI
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"
APP_VERSION="11.14"
APP_TITLE="OpenClaw & AI Infrastructure - Ultimate Setup V${APP_VERSION}"

# Installationsverzeichnis
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
USER_OPENCLAW_TEMPLATE_DIR="$USER_WORKSPACE_DIR/openclaw"
USER_PROFILE_SOURCE_DIR="$USER_WORKSPACE_DIR/profil_quellen"
USER_PROFILE_RENDERED_DIR="$USER_WORKSPACE_DIR/profile_ableitungen"
USER_PROMPTS_DIR="$USER_WORKSPACE_DIR/prompts"
USER_MODELFILE_DIR="$USER_WORKSPACE_DIR/modelfiles"
USER_METRICS_LOG_DIR="$USER_WORKSPACE_DIR/metrics_logs"
USER_DIALOGRC_FILE="$USER_WORKSPACE_DIR/dialogrc"
METRICS_CONFIG_FILE="$USER_WORKSPACE_DIR/setup_metrics.conf"
METRICS_HISTORY_FILE="$USER_METRICS_LOG_DIR/operation_history.tsv"
PROFILE_STATUS_FILE="$USER_WORKSPACE_DIR/installed_profiles.txt"
TOOL_STATUS_FILE="$USER_WORKSPACE_DIR/installed_tools.txt"
SETUP_PREFERENCES_FILE="$USER_WORKSPACE_DIR/setup_preferences.conf"
SCRIPT_ROOT_DIR="$INSTALL_DIR"
LANGUAGE_SELECTION_REQUIRED=0
STARTUP_LANGUAGE_DIALOG_PENDING=0

if [ ! -f "$SETUP_PREFERENCES_FILE" ]; then
    LANGUAGE_SELECTION_REQUIRED=1
fi

source "$INSTALL_DIR/scripts/lang/common.sh"
load_setup_language

ensure_user_workspace() {
    ensure_setup_preferences
    mkdir -p "$USER_WORKSPACE_DIR"
    mkdir -p "$USER_OPENCLAW_TEMPLATE_DIR"
    mkdir -p "$USER_PROFILE_SOURCE_DIR"
    mkdir -p "$USER_PROFILE_RENDERED_DIR"
    mkdir -p "$USER_PROMPTS_DIR"
    mkdir -p "$USER_MODELFILE_DIR"
    mkdir -p "$USER_METRICS_LOG_DIR"

    if [ ! -f "$USER_OPENCLAW_TEMPLATE_DIR/.env.template" ]; then
        cp "$INSTALL_DIR/scripts/config_templates/openclaw/.env.template" "$USER_OPENCLAW_TEMPLATE_DIR/.env.template"
    fi

    if [ ! -f "$USER_OPENCLAW_TEMPLATE_DIR/config.json.template" ]; then
        cp "$INSTALL_DIR/scripts/config_templates/openclaw/config.json.template" "$USER_OPENCLAW_TEMPLATE_DIR/config.json.template"
    fi

    if [ -d "$INSTALL_DIR/docs/Profil" ]; then
        find "$INSTALL_DIR/docs/Profil" -maxdepth 1 -type f -name '*.doc.md' | while IFS= read -r source_file; do
            target_file="$USER_PROFILE_SOURCE_DIR/$(basename "$source_file")"
            if [ ! -f "$target_file" ]; then
                cp "$source_file" "$target_file"
            fi
        done
    fi

    if [ -d "$INSTALL_DIR/docs/Profile" ]; then
        find "$INSTALL_DIR/docs/Profile" -maxdepth 1 -type f -name '*.md' | while IFS= read -r rendered_file; do
            target_file="$USER_PROFILE_RENDERED_DIR/$(basename "$rendered_file")"
            if [ ! -f "$target_file" ]; then
                cp "$rendered_file" "$target_file"
            fi
        done
    fi

    if [ ! -f "$USER_PROMPTS_DIR/README.txt" ]; then
        cat > "$USER_PROMPTS_DIR/README.txt" <<'EOF'
Hier können künftig benutzerdefinierte Prompt-Dateien abgelegt werden.
Diese Dateien liegen bewusst außerhalb des Repositories, damit sie bei Updates erhalten bleiben
und nicht versehentlich in Git oder GitHub landen.
EOF
    fi

    cat > "$USER_DIALOGRC_FILE" <<'EOF'
# Ausgelagerte dialog-Farben für das Ultimate Setup
use_colors = ON
use_shadow = OFF
screen_color = (WHITE,BLUE,ON)
shadow_color = (BLACK,BLACK,ON)
dialog_color = (BLACK,WHITE,OFF)
title_color = (YELLOW,WHITE,ON)
border_color = (BLUE,WHITE,ON)
button_active_color = (WHITE,BLUE,ON)
button_inactive_color = (BLACK,WHITE,OFF)
button_key_active_color = (WHITE,BLUE,ON)
button_key_inactive_color = (BLUE,WHITE,ON)
button_label_active_color = (WHITE,BLUE,ON)
button_label_inactive_color = (BLACK,WHITE,ON)
check_color = (BLACK,WHITE,OFF)
check_selected_color = (WHITE,BLUE,ON)
tag_color = (BLUE,WHITE,ON)
tag_selected_color = (WHITE,BLUE,ON)
item_color = (BLACK,WHITE,OFF)
item_selected_color = (WHITE,BLUE,ON)
inputbox_color = (BLACK,WHITE,OFF)
inputbox_border_color = (BLUE,WHITE,ON)
searchbox_color = (BLACK,WHITE,OFF)
searchbox_title_color = (YELLOW,WHITE,ON)
menubox_color = (BLACK,WHITE,OFF)
menubox_border_color = (BLUE,WHITE,ON)
position_indicator_color = (YELLOW,WHITE,ON)
uarrow_color = (BLUE,WHITE,ON)
darrow_color = (BLUE,WHITE,ON)
EOF

    if [ ! -f "$METRICS_HISTORY_FILE" ]; then
        printf 'timestamp\toperation_id\toperation_title\tstatus\tduration_seconds\tfree_kb_before\tfree_kb_after\tdelta_kb\n' > "$METRICS_HISTORY_FILE"
    fi

    touch "$PROFILE_STATUS_FILE" "$TOOL_STATUS_FILE"
    export DIALOGRC="$USER_DIALOGRC_FILE"
}

ensure_metrics_config() {
    ensure_user_workspace
    if [ ! -f "$METRICS_CONFIG_FILE" ]; then
        cat > "$METRICS_CONFIG_FILE" <<'EOF'
# Editierbare Schätz- und Testwerte für dieses Setup
# Stand: Letsung MiniPC Testziel mit Windows 11 original + Ubuntu 24.04 LTS in WSL2

TARGET_DEVICE_NAME="Letsung MiniPC"
TARGET_HOST_OS="Windows 11 original"
TARGET_LINUX_OS="Ubuntu 24.04 LTS (WSL2)"
MIN_FREE_GB_RECOMMENDED="80"
MIN_FREE_GB_ABSOLUTE="50"

OS_DOWNLOAD_TIME_ESTIMATE="5-15 min"
OS_INSTALL_TIME_ESTIMATE="10-25 min"
SETUP_DOWNLOAD_TIME_ESTIMATE="< 1 min"
SETUP_INSTALL_TIME_ESTIMATE="20-60 min"
UBUNTU_UPDATES_DOWNLOAD_TIME_ESTIMATE="5-20 min"
UBUNTU_UPDATES_INSTALL_TIME_ESTIMATE="10-30 min"
OPENCLAW_DOWNLOAD_TIME_ESTIMATE="2-10 min"
OPENCLAW_BUILD_TIME_ESTIMATE="10-40 min"
OLLAMA_INSTALL_TIME_ESTIMATE="2-10 min"
HOME_ASSISTANT_INSTALL_TIME_ESTIMATE="5-20 min"
CLOUDFLARED_INSTALL_TIME_ESTIMATE="2-10 min"
LOCAL_SETUP_TOTAL_ESTIMATE="25-70 min"
LOCAL_SETUP_CONFIRM_STOP_1_ESTIMATE="12-35 min"
LOCAL_SETUP_CONFIRM_STOP_2_ESTIMATE="18-45 min"
LOCAL_SETUP_CLOUDFLARE_TOKEN_STOP_ESTIMATE="22-60 min"

PROGRAMMIERER_REQUIRED_GB="8-20"
MEDIA_MUSIK_REQUIRED_GB="15-40"
KI_FORSCHUNG_REQUIRED_GB="15-50"
MARKETING_REQUIRED_GB="8-20"
RECHT_STEUER_REQUIRED_GB="6-15"
AGENT_ORCHESTRATOR_REQUIRED_GB="10-25"
AUDIO_REQUIRED_GB="8-20"
CONTENT_AUTOMATION_REQUIRED_GB="12-30"
RESEARCH_AGENT_REQUIRED_GB="8-20"
SECURITY_ANALYST_REQUIRED_GB="5-15"
TRADING_AI_REQUIRED_GB="8-20"
VISUAL_CREATOR_REQUIRED_GB="20-60"
LLM_BUILDER_REQUIRED_GB="25-120"

NOTES="Alle Werte sind editierbare Schätzwerte. Je nach Bandbreite, CPU, SSD und gewählten Profilen kann der echte Wert deutlich abweichen."
EOF
    fi
}

show_metrics_editor() {
    ensure_metrics_config
    dialog --clear --backtitle "$APP_TITLE" \
    --title "SETUP-MESSWERTE & BENCHMARKS" --editbox "$METRICS_CONFIG_FILE" 30 110 2> /tmp/metrics_config_edit

    if [ $? -eq 0 ]; then
        cp /tmp/metrics_config_edit "$METRICS_CONFIG_FILE"
        echo -e "${GREEN}Die editierbaren Setup-Messwerte wurden aktualisiert.${NC}"
    fi
}

load_metrics_config() {
    ensure_metrics_config
    # shellcheck source=/dev/null
    source "$METRICS_CONFIG_FILE"
    : "${LOCAL_SETUP_TOTAL_ESTIMATE:=$SETUP_INSTALL_TIME_ESTIMATE}"
    : "${LOCAL_SETUP_CONFIRM_STOP_1_ESTIMATE:=12-35 min}"
    : "${LOCAL_SETUP_CONFIRM_STOP_2_ESTIMATE:=18-45 min}"
    : "${LOCAL_SETUP_CLOUDFLARE_TOKEN_STOP_ESTIMATE:=22-60 min}"
}

reset_terminal_display() {
    printf '\033[0m'
    tput sgr0 2>/dev/null || true
}

get_free_disk_kb() {
    df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}'
}

format_duration_human() {
    local total_seconds="$1"
    local minutes=$((total_seconds / 60))
    local seconds=$((total_seconds % 60))

    if [ "$minutes" -gt 0 ]; then
        printf '%s min %s s' "$minutes" "$seconds"
    else
        printf '%s s' "$seconds"
    fi
}

begin_operation_measurement() {
    ensure_user_workspace
    ACTIVE_OPERATION_ID="$1"
    ACTIVE_OPERATION_TITLE="$2"
    ACTIVE_OPERATION_STARTED_AT="$(date +%s)"
    ACTIVE_OPERATION_FREE_KB_BEFORE="$(get_free_disk_kb)"
}

end_operation_measurement() {
    local operation_status="$1"
    local ended_at
    local free_kb_after
    local duration_seconds
    local delta_kb

    [ -n "${ACTIVE_OPERATION_STARTED_AT:-}" ] || return 0

    ended_at="$(date +%s)"
    free_kb_after="$(get_free_disk_kb)"
    duration_seconds=$((ended_at - ACTIVE_OPERATION_STARTED_AT))
    delta_kb=$((ACTIVE_OPERATION_FREE_KB_BEFORE - free_kb_after))

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "${ACTIVE_OPERATION_ID:-unbekannt}" \
        "${ACTIVE_OPERATION_TITLE:-Unbekannt}" \
        "$operation_status" \
        "$duration_seconds" \
        "${ACTIVE_OPERATION_FREE_KB_BEFORE:-0}" \
        "${free_kb_after:-0}" \
        "$delta_kb" >> "$METRICS_HISTORY_FILE"

    echo -e "${YELLOW}Messwert gespeichert:${NC} ${ACTIVE_OPERATION_TITLE:-Unbekannt} | Status: $operation_status | Dauer: $(format_duration_human "$duration_seconds") | Speicheränderung: ${delta_kb} KB"

    unset ACTIVE_OPERATION_ID ACTIVE_OPERATION_TITLE ACTIVE_OPERATION_STARTED_AT ACTIVE_OPERATION_FREE_KB_BEFORE
}

show_recent_measurements() {
    ensure_user_workspace

    if [ ! -f "$METRICS_HISTORY_FILE" ]; then
        echo -e "${YELLOW}Es liegen noch keine Messwerte vor.${NC}"
        read -p "Drücken Sie Enter..."
        return 0
    fi

    clear
    echo
    echo -e "${YELLOW}Letzte Messwerte aus dem Benutzer-Workspace:${NC}"
    echo -e "${YELLOW}Datei:${NC} $METRICS_HISTORY_FILE"
    echo
    tail -n 20 "$METRICS_HISTORY_FILE"
    echo
    read -p "Drücken Sie Enter..."
}

show_operation_intro() {
    local operation_title="$1"
    local operation_summary="$2"
    local operation_duration="$3"
    local operation_storage="$4"
    local operation_notes="${5:-}"

    load_metrics_config
    clear
    echo
    echo -e "${YELLOW}Willkommen im ${APP_TITLE}.${NC}"
    echo -e "${YELLOW}Es startet jetzt: ${operation_title}${NC}"
    echo
    echo -e "${YELLOW}Was passiert:${NC} ${operation_summary}"
    echo -e "${YELLOW}Geschaetzte Dauer:${NC} ${operation_duration}"
    echo -e "${YELLOW}Empfohlener freier Speicher:${NC} ${operation_storage}"
    echo -e "${YELLOW}Hinweis:${NC} Mehrere sudo-/Passwortabfragen sind normal. Gemeint ist das Linux-/Ubuntu-Passwort deines Users."
    echo -e "${YELLOW}Hinweis:${NC} Die Zeiten sind nur Schaetzwerte und haengen von SSD, CPU, RAM, Internet und den gewaehlten Modulen ab."
    if [ -n "$operation_notes" ]; then
        echo -e "${YELLOW}Zusatz:${NC} ${operation_notes}"
    fi
    echo
    sleep 4
}

get_profile_required_gb() {
    local profile_key="$1"

    load_metrics_config

    case "$profile_key" in
        "Programmierer") echo "${PROGRAMMIERER_REQUIRED_GB} GB" ;;
        "Media_Musik") echo "${MEDIA_MUSIK_REQUIRED_GB} GB" ;;
        "KI_Forschung") echo "${KI_FORSCHUNG_REQUIRED_GB} GB" ;;
        "Texter_Werbung_Marketing") echo "${MARKETING_REQUIRED_GB} GB" ;;
        "Rechtsberatung_Steuerrecht") echo "${RECHT_STEUER_REQUIRED_GB} GB" ;;
        "Agent_Orchestrator") echo "${AGENT_ORCHESTRATOR_REQUIRED_GB} GB" ;;
        "Audio") echo "${AUDIO_REQUIRED_GB} GB" ;;
        "Content_Automation") echo "${CONTENT_AUTOMATION_REQUIRED_GB} GB" ;;
        "Research_Agent") echo "${RESEARCH_AGENT_REQUIRED_GB} GB" ;;
        "Security_Analyst") echo "${SECURITY_ANALYST_REQUIRED_GB} GB" ;;
        "Trading_AI") echo "${TRADING_AI_REQUIRED_GB} GB" ;;
        "Visual_Creator") echo "${VISUAL_CREATOR_REQUIRED_GB} GB" ;;
        "LLM_Builder") echo "${LLM_BUILDER_REQUIRED_GB} GB" ;;
        *) echo "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB" ;;
    esac
}

show_profile_action_intro() {
    local profile_key="$1"
    local action_label="$2"
    local required_gb

    required_gb="$(get_profile_required_gb "$profile_key")"
    show_operation_intro \
    "Profil ${action_label}: ${profile_key}" \
    "${PROFILES[$profile_key]}" \
    "${SETUP_DOWNLOAD_TIME_ESTIMATE} Download + ${SETUP_INSTALL_TIME_ESTIMATE} Installation/Anpassung je nach Profilgroesse" \
    "$required_gb" \
    "Je nach Profil werden mehrere Einzeltools nacheinander installiert oder entfernt. Das kann laenger dauern als bei einem Einzeltool."
}

show_tool_action_intro() {
    local tool_key="$1"
    local action_label="$2"

    show_operation_intro \
    "Tool ${action_label}: ${tool_key}" \
    "${TOOLS[$tool_key]}" \
    "${SETUP_DOWNLOAD_TIME_ESTIMATE} Download + ${SETUP_INSTALL_TIME_ESTIMATE} Installation/Anpassung je nach Tool" \
    "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB" \
    "Einige Tools benoetigen zusaetzliche Paketquellen, Builds, Container oder API-Eingaben."
}

run_bash_script() {
    local script_path="$1"

    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Fehler: Skript nicht gefunden: $script_path${NC}"
        return 1
    fi

    bash "$script_path"
    local script_rc=$?
    reset_terminal_display
    return $script_rc
}

print_exit_message() {
    clear
    echo
    echo -e "${YELLOW}${TXT_EXIT_LINE_1:-Setup beendet. Bis zum naechsten Mal.}${NC}"
    echo -e "${YELLOW}${TXT_EXIT_LINE_2:-Zum Neustart siehe README oder direkt:}${NC}"
    echo -e "${YELLOW}${TXT_EXIT_RESTART:-cd ~/openclaw_ultimate_setup && bash ./setup_ultimate.sh}${NC}"
    echo
}

show_user_workspace_menu() {
    ensure_user_workspace

    while true; do
        dialog --clear --backtitle "$APP_TITLE" \
        --title "${TXT_WORKSPACE_MENU_TITLE:-BENUTZER-WORKSPACE}" --menu "${TXT_WORKSPACE_MENU_PROMPT:-Bearbeitbare und sensible Dateien liegen außerhalb des Repos.}" 22 104 9 \
        "1" "${TXT_WORKSPACE_OPTION_1:-Pfad anzeigen}" \
        "2" "${TXT_WORKSPACE_OPTION_2:-Workspace-Dateien auflisten}" \
        "3" "${TXT_WORKSPACE_OPTION_3:-OpenClaw Vorlagen aus dem Repo neu in den Workspace kopieren}" \
        "4" "${TXT_WORKSPACE_OPTION_4:-Profil-Quellen und Profilseiten aus dem Repo neu in den Workspace kopieren}" \
        "5" "${TXT_WORKSPACE_OPTION_5:-Prompt-Bereich im Workspace anzeigen}" \
        "6" "${TXT_WORKSPACE_OPTION_6:-Letzte Messwerte anzeigen}" \
        "7" "${TXT_WORKSPACE_OPTION_7:-Benutzer-Workspace komplett löschen}" \
        "8" "${TXT_WORKSPACE_OPTION_8:-Sprache ändern}" \
        "9" "${TXT_WORKSPACE_OPTION_9:-Zurück}" 2> /tmp/user_workspace_choice

        if [ $? -ne 0 ]; then
            return 0
        fi

        case "$(cat /tmp/user_workspace_choice)" in
            1)
                clear
                echo
                echo -e "${YELLOW}${TXT_WORKSPACE_PATH_LABEL:-Benutzer-Workspace:}${NC} $USER_WORKSPACE_DIR"
                echo
                read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                ;;
            2)
                clear
                echo
                echo -e "${YELLOW}${TXT_WORKSPACE_CONTENT_LABEL:-Inhalt des Benutzer-Workspace:}${NC}"
                find "$USER_WORKSPACE_DIR" -maxdepth 3 -type f 2>/dev/null | sort
                echo
                read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                ;;
            3)
                cp "$INSTALL_DIR/scripts/config_templates/openclaw/.env.template" "$USER_OPENCLAW_TEMPLATE_DIR/.env.template"
                cp "$INSTALL_DIR/scripts/config_templates/openclaw/config.json.template" "$USER_OPENCLAW_TEMPLATE_DIR/config.json.template"
                echo -e "${GREEN}${TXT_WORKSPACE_OPENCLAW_COPIED:-Die OpenClaw-Vorlagen wurden erneut in den Benutzer-Workspace kopiert.}${NC}"
                read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                ;;
            4)
                if [ -d "$INSTALL_DIR/docs/Profil" ]; then
                    find "$INSTALL_DIR/docs/Profil" -maxdepth 1 -type f -name '*.doc.md' -exec cp {} "$USER_PROFILE_SOURCE_DIR/" \;
                fi
                if [ -d "$INSTALL_DIR/docs/Profile" ]; then
                    find "$INSTALL_DIR/docs/Profile" -maxdepth 1 -type f -name '*.md' -exec cp {} "$USER_PROFILE_RENDERED_DIR/" \;
                fi
                echo -e "${GREEN}${TXT_WORKSPACE_PROFILES_COPIED:-Profil-Quellen und abgeleitete Profilseiten wurden erneut in den Benutzer-Workspace kopiert.}${NC}"
                read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                ;;
            5)
                clear
                echo
                echo -e "${YELLOW}${TXT_WORKSPACE_PROMPTS_LABEL:-Prompt-Bereich im Benutzer-Workspace:}${NC} $USER_PROMPTS_DIR"
                echo
                find "$USER_PROMPTS_DIR" -maxdepth 2 -type f 2>/dev/null | sort
                echo
                read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                ;;
            6)
                show_recent_measurements
                ;;
            7)
                dialog --yesno "${TXT_WORKSPACE_DELETE_CONFIRM:-Der gesamte Benutzer-Workspace wird gelöscht. Darin können .env-Vorlagen, Statusdateien und weitere sensible Daten liegen. Wirklich fortfahren?}" 10 100
                if [ $? -eq 0 ]; then
                    rm -rf "$USER_WORKSPACE_DIR"
                    echo -e "${YELLOW}${TXT_WORKSPACE_DELETED:-Der Benutzer-Workspace wurde gelöscht.}${NC}"
                    ensure_user_workspace
                    read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                fi
                ;;
            8)
                if show_setup_language_menu; then
                    echo -e "${GREEN}${TXT_LANGUAGE_CHANGED:-Die Setup-Sprache wurde aktualisiert.}${NC}"
                    read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                fi
                ;;
            9)
                return 0
                ;;
        esac
    done
}

show_options_menu() {
    while true; do
        dialog --clear --backtitle "$APP_TITLE" \
        --title "${TXT_OPTIONS_MENU_TITLE:-OPTIONEN}" --menu "${TXT_OPTIONS_MENU_PROMPT:-Wählen Sie eine Verwaltungs- oder Konfigurationsfunktion:}" 20 92 7 \
        "1" "${TXT_OPTIONS_1:-Sprache ändern}" \
        "2" "${TXT_OPTIONS_2:-Setup-Messwerte & Benchmarks bearbeiten}" \
        "3" "${TXT_OPTIONS_3:-Ollama Modelfile-Assistent}" \
        "4" "${TXT_OPTIONS_4:-Setup hart mit GitHub main abgleichen}" \
        "5" "${TXT_OPTIONS_5:-Benutzer-Workspace verwalten}" \
        "6" "${TXT_OPTIONS_6:-Zurück}" 2> /tmp/options_choice

        if [ $? -ne 0 ]; then
            return 0
        fi

        case "$(cat /tmp/options_choice)" in
            1)
                if show_setup_language_menu; then
                    echo -e "${GREEN}${TXT_LANGUAGE_CHANGED:-Die Setup-Sprache wurde aktualisiert.}${NC}"
                    read -p "${TXT_PRESS_ENTER:-Drücken Sie Enter...}"
                fi
                ;;
            2)
                show_metrics_editor
                read -p "Setup-Messwerte aktualisiert. Drücken Sie Enter..."
                ;;
            3)
                run_bash_script "$INSTALL_DIR/scripts/ollama_modelfile_assistant.sh"
                ;;
            4)
                show_operation_intro \
                "Harter Setup-Abgleich mit GitHub main" \
                "Das Setup-Repository wird zwangsweise auf origin/main zurückgesetzt. Lokale Änderungen im Setup-Verzeichnis gehen dabei verloren." \
                "Meist nur wenige Minuten, abhängig von Netzwerk und Repo-Größe" \
                "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB" \
                "Nutze diese Methode nur, wenn das normale Update nicht greift oder ein alter Setup-Stand festhaengt."
                run_bash_script "$INSTALL_DIR/scripts/auto_update_hard.sh"
                read -p "Harter Setup-Abgleich abgeschlossen. Drücken Sie Enter..."
                ;;
            5)
                show_user_workspace_menu
                ;;
            6)
                return 0
                ;;
        esac
    done
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
    local -n target_map="$map_name"

    [ -f "$file_path" ] || return 0

    while IFS= read -r entry_name || [ -n "$entry_name" ]; do
        entry_name="${entry_name%$'\r'}"
        entry_name="${entry_name//\"/}"
        [ -n "$entry_name" ] || continue
        target_map["$entry_name"]=1
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

sync_core_tool_status() {
    local status_changed=0

    ensure_user_workspace
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"

    if command -v ollama >/dev/null 2>&1; then
        if ! grep -Fxq "Ollama" "$TOOL_STATUS_FILE" 2>/dev/null; then
            append_unique_line "$TOOL_STATUS_FILE" "Ollama"
            status_changed=1
        fi
    fi

    if [ -d /opt/openclaw ] && [ -f /opt/openclaw/package.json ]; then
        if ! grep -Fxq "OpenClaw" "$TOOL_STATUS_FILE" 2>/dev/null; then
            append_unique_line "$TOOL_STATUS_FILE" "OpenClaw"
            status_changed=1
        fi
    fi

    if [ "$status_changed" -eq 1 ]; then
        echo -e "${BLUE}Hinweis: Der Tool-Status fuer Ollama/OpenClaw wurde aus der vorhandenen Systeminstallation nachsynchronisiert.${NC}"
    fi
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
PROFILE_KEYS=("Programmierer" "Media_Musik" "KI_Forschung" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht" "Agent_Orchestrator" "Audio" "Content_Automation" "Research_Agent" "Security_Analyst" "Trading_AI" "Visual_Creator" "LLM_Builder")
PROFILES["Programmierer"]="Tools für Entwicklung, Code-Generierung (DeepSeek Coder), Git-Integration, Huginn, Clawhub CLI. Ideal für Entwickler und Automatisierungsexperten."
PROFILES["Media_Musik"]="Tools für Audio/Video (FFmpeg), Audio-AI, Alexa-Integration, Clawbake. Für Content Creator und Medienproduzenten."
PROFILES["KI_Forschung"]="Spezialisierte Bibliotheken für Reinforcement Learning (OpenClaw RL), erweiterte LLM-Modelle (Gemini-1.5-Pro), Flowise/LangFlow. Für KI-Wissenschaftler und Forscher."
PROFILES["Texter_Werbung_Marketing"]="Tools für Content-Generierung, SEO-Analyse, Social Media, Textproduktion, n8n, Activepieces. Optimiert für Marketingexperten und Texter, die ihre Inhalte mit KI verbessern möchten."
PROFILES["Rechtsberatung_Steuerrecht"]="Tools für Web-Search & Fetch, PDF-Reader/Document-Parser, Zotero. Für die Analyse von Rechtsdokumenten und Steuerrecht, unterstützt durch spezialisierte KI-Agenten."
PROFILES["Agent_Orchestrator"]="Koordiniert Agentenrollen mit LangGraph, CrewAI, AutoGen und Memory-Bausteinen für Routing und Ergebnis-Synchronisierung."
PROFILES["Audio"]="Verarbeitet Sprache und Audio mit Speech-to-Text, Text-to-Speech und Cleanup-Bausteinen wie Whisper, Piper und Coqui TTS."
PROFILES["Content_Automation"]="Automatisiert Content-Pipelines von Skript über Voiceover und Videoschnitt bis zu Upload-Workflows."
PROFILES["Research_Agent"]="Analysiert Repositories, Dokumentation und neue Tools, um das Setup gezielt weiterzuentwickeln."
PROFILES["Security_Analyst"]="Fokussiert auf Exposure-Checks, Log-Analyse, Schwachstellensuche und Docker-/Kubernetes-Hardening."
PROFILES["Trading_AI"]="Unterstützt Marktanalyse, Strategietests und Trading-Bots mit Zenbot sowie Web3- und Exchange-Integrationen."
PROFILES["Visual_Creator"]="Kreativprofil für Bild-, Video- und Asset-Pipelines mit Diffusions-, UI- und Upscaling-Bausteinen."
PROFILES["LLM_Builder"]="Baut einen realistischen lokalen Workflow zum Fine-Tuning, Testen, Exportieren und Quantisieren eigener Modelle für Ollama auf."

# Funktion zum Installieren eines Profils
install_profile() {
    local PROFILE_KEY="$1"
    show_profile_action_intro "$PROFILE_KEY" "installieren"
    begin_operation_measurement "profile_install_${PROFILE_KEY}" "Profil installieren: ${PROFILE_KEY}"
    echo -e "${BLUE}Installiere Profil: ${PROFILE_KEY}...${NC}"
    run_bash_script "$INSTALL_DIR/scripts/profiles/${PROFILE_KEY}_install.sh"
    if [ $? -eq 0 ]; then
        append_unique_line "$PROFILE_STATUS_FILE" "$PROFILE_KEY"
        end_operation_measurement "success"
        echo -e "${GREEN}Profil \'$PROFILE_KEY\' erfolgreich installiert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Installation von Profil \'$PROFILE_KEY\'.${NC}"
    fi
}

# Funktion zum Deinstallieren eines Profils
uninstall_profile() {
    local PROFILE_KEY="$1"
    show_profile_action_intro "$PROFILE_KEY" "deinstallieren"
    begin_operation_measurement "profile_uninstall_${PROFILE_KEY}" "Profil deinstallieren: ${PROFILE_KEY}"
    echo -e "${BLUE}Deinstalliere Profil: ${PROFILE_KEY}...${NC}"
    run_bash_script "$INSTALL_DIR/scripts/profiles/${PROFILE_KEY}_uninstall.sh"
    if [ $? -eq 0 ]; then
        remove_exact_line "$PROFILE_STATUS_FILE" "$PROFILE_KEY"
        end_operation_measurement "success"
        echo -e "${GREEN}Profil \'$PROFILE_KEY\' erfolgreich deinstalliert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Deinstallation von Profil \'$PROFILE_KEY\'.${NC}"
    fi
}

# Funktion zum Anzeigen des Profil-Management-Menüs
show_profile_management_menu() {
    ensure_user_workspace
    normalize_status_file "$PROFILE_STATUS_FILE" "${PROFILE_KEYS[@]}"

    if ! is_base_install_ready; then
        echo -e "${YELLOW}Hinweis: Ollama und/oder OpenClaw sind aktuell noch nicht vollständig installiert.${NC}"
        echo -e "${YELLOW}Die Profilverwaltung kann trotzdem geöffnet werden. Einige Profile benötigen für die volle Funktion aber die Basis-Installation.${NC}"
    fi

    # Installierte Profile laden
    declare -A INSTALLED_PROFILES_MAP
    load_installed_map "$PROFILE_STATUS_FILE" INSTALLED_PROFILES_MAP

    PROFILE_CHECKLIST_OPTIONS=()
    for profile_key in "${PROFILE_KEYS[@]}"; do
        STATUS="off"
        if [ -n "$profile_key" ] && [ "${INSTALLED_PROFILES_MAP[$profile_key]:-}" = "1" ]; then
            STATUS="on"
        fi
        PROFILE_CHECKLIST_OPTIONS+=("$profile_key" "${PROFILES[$profile_key]}" "$STATUS")
    done

    dialog --clear --backtitle "$APP_TITLE" \
    --title "PROFIL-MANAGEMENT" --checklist "Wählen Sie Profile zum Installieren/Deinstallieren:" 30 100 18 \
    "${PROFILE_CHECKLIST_OPTIONS[@]}" 2> /tmp/profile_selection

    if [ $? -ne 0 ]; then
        return 0
    fi

    mapfile -t SELECTED_PROFILES_ARRAY < <(tr ' ' '\n' < /tmp/profile_selection | tr -d '"' | sed '/^$/d')

    # Installation/Deinstallation basierend auf Auswahl
    for profile_key in "${PROFILE_KEYS[@]}"; do
        if selection_contains "$profile_key" "${SELECTED_PROFILES_ARRAY[@]}" && [ "${INSTALLED_PROFILES_MAP[$profile_key]:-}" != "1" ]; then
            # Profil ausgewählt und nicht installiert -> Installieren
            install_profile "$profile_key"
        elif ! selection_contains "$profile_key" "${SELECTED_PROFILES_ARRAY[@]}" && [ "${INSTALLED_PROFILES_MAP[$profile_key]:-}" = "1" ]; then
            # Profil nicht ausgewählt und installiert -> Deinstallieren
            uninstall_profile "$profile_key"
        fi
    done
    read -p "Profil-Management abgeschlossen. Drücken Sie Enter..."
}

# --- Funktionen für Tool-Management ---

declare -A TOOLS
declare -A TOOL_SCRIPT_NAMES
TOOL_KEYS=("Ollama" "OpenManus" "OpenClaw" "Clawhub_CLI" "OpenClaw_RL" "Clawbake" "n8n" "Activepieces" "Flowise" "LangFlow" "AutoGPT" "Pipedream" "Huginn" "FFmpeg" "LangGraph" "CrewAI" "AutoGen" "Playwright" "ChromaDB" "LangChain" "LlamaIndex" "MLflow" "Whisper" "librosa" "pydub" "Demucs" "Zenbot_trader" "Kimi2" "Clawhub" "Huge_Facing" "Zotero" "Piper" "Coqui_TTS" "YT_DLP" "Web3_APIs" "Exchange_APIs" "Nmap" "Nikto" "Trivy" "Fail2Ban" "Stable_Diffusion_WebUI" "ComfyUI" "RealESRGAN" "Redis" "NATS" "Qdrant" "Weaviate" "Prometheus" "Grafana" "Loki" "Trend_Monitor" "Agent_Router" "Memory_Policies" "Voice_Assistant_Runtime" "Thumbnail_Pipeline" "Upload_Automation" "Weights_and_Biases" "vLLM" "Llama_CPP" "Ray" "EnviroLLM" "Suno_API" "Udio_API" "MusicGen" "Riffusion" "ControlNet" "Music2P_Pipeline" "Hook_Detection" "BPM_Analyzer" "TikTok_Score" "Emotion_Tagging" "Docker" "Kubernetes" "K3s" "GitHub_API_Tooling" "Code_Sandbox" "VS_Code_Server" "Puppeteer" "OpenTelemetry" "Vault" "SQLite" "Postgres" "RabbitMQ" "EULLM" "AI_Powered_Law_Firms" "Lawfirm" "Tax_Law_Agent" "Risk_Agent" "Drafting_Agent" "PDF_Parser" "Neo4j" "Tax_Calculator" "Deadline_Checker" "Risk_Scoring" "GitHub_Research" "Repo_Comparison" "Fail2Ban_Analyzer" "Security_Workflow" "Browser_Tool" "Firecrawl" "Google_Analytics_API" "Meta_Ads_API" "TikTok_Ads_API" "File_System_Tool" "HubSpot" "Notion" "Airtable" "Buffer_API" "Zapier" "Make" "Ahrefs" "SEMrush" "ElevenLabs" "Zenbot_API" "Risk_Strategy_Analyzer" "Backtest_Workflow" "AnimateDiff" "SVD" "Runway_API" "Image_Upscaler_Pipeline" "Aider" "OpenCode" "OpenHands" "GitHub_CLI" "Podman" "Unsloth" "LLaMA_Factory" "Axolotl" "Data_Juicer" "Llama_CPP_Toolchain")
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
TOOLS["Piper"]="Lokale Text-to-Speech Engine für Voiceover, Audio-Profile und Assistenzsysteme."
TOOLS["Coqui_TTS"]="Lokale Text-to-Speech Pipeline für Sprachsynthese und Content-Automation."
TOOLS["YT_DLP"]="Downloader und Eingangsbaustein für Video- und Audioquellen in Content-Pipelines."
TOOLS["Web3_APIs"]="Web3- und Blockchain-Bibliotheken für On-Chain-Daten und Trading-Integrationen."
TOOLS["Exchange_APIs"]="Börsen- und Marktdatenbibliotheken für Trading-Bots und Strategietests."
TOOLS["Nmap"]="Port- und Netzwerkscanner für Security-Checks und Exposure-Analysen."
TOOLS["Nikto"]="Webserver-Scanner für grundlegende Sicherheits- und Exposure-Prüfungen."
TOOLS["Trivy"]="Scanner für Container, Images und Abhängigkeiten mit Fokus auf Sicherheitslücken."
TOOLS["Fail2Ban"]="Schutz- und Log-Baustein gegen auffällige Login-Muster und Brute-Force-Versuche."
TOOLS["Stable_Diffusion_WebUI"]="WebUI-basierte Bildgenerierung und Prompt-Arbeit für visuelle Pipelines."
TOOLS["ComfyUI"]="Node-basierte visuelle Pipeline für Bild- und Video-Workflows."
TOOLS["RealESRGAN"]="Upscaling-Tool für Bilder, Thumbnails und visuelle Assets."
TOOLS["Redis"]="Queue- und Cache-Baustein für Agentenorchestrierung, State-Sharing und Workflow-Puffer."
TOOLS["NATS"]="Event-Bus für leichtgewichtige Agentenkommunikation und Signale."
TOOLS["Qdrant"]="Vektor-Datenbank für Memory, Retrieval und profilübergreifendes Wissensrouting."
TOOLS["Weaviate"]="Vektor- und Wissensschicht für komplexere Retrieval- und Schema-Workflows."
TOOLS["Prometheus"]="Metrics- und Monitoring-Baustein für Dienste, Agenten und Pipelines."
TOOLS["Grafana"]="Dashboard- und Visualisierungsschicht für Metriken, Trends und Betriebszustände."
TOOLS["Loki"]="Log-Aggregation für Profile, Services und Agentenläufe."
TOOLS["Trend_Monitor"]="Trend- und Feed-Monitoring für Recherche- und Content-Automation-Pipelines."
TOOLS["Agent_Router"]="Routing-Modul für Multi-Agent-Entscheidungen, Rollenverteilung und Übergaben."
TOOLS["Memory_Policies"]="Policy-Sammlung für Agenten-Memory, Konfliktauflösung und Kontextübergaben."
TOOLS["Voice_Assistant_Runtime"]="Vorkonfiguriertes Laufzeitmodul für Speech-to-Text, TTS und Antwortverkettung."
TOOLS["Thumbnail_Pipeline"]="Bild- und Thumbnail-Pipeline für Content-Automation und visuelle Publishing-Flows."
TOOLS["Upload_Automation"]="Connector-Modul für Upload-, Publish- und Übergabe-Workflows."
TOOLS["Weights_and_Biases"]="Experiment-Tracking und Vergleich von Trainingsläufen für KI-Forschung."
TOOLS["vLLM"]="Inference-Engine für leistungsfähige LLM-Serving-Workloads."
TOOLS["Llama_CPP"]="Lokale llama.cpp-Anbindung für GGUF-Modelle und experimentelle Inferenz."
TOOLS["Ray"]="Verteiltes Compute-Framework für Parallelisierung, Datenverarbeitung und Agentenexperimente."
TOOLS["EnviroLLM"]="Scaffold-Modul für umgebungs- und simulationsnahe LLM-Experimente."
TOOLS["Suno_API"]="Connector-Modul für Suno-nahe Musikgenerierungs-Workflows."
TOOLS["Udio_API"]="Connector-Modul für Udio-nahe Musik- und Prompt-Workflows."
TOOLS["MusicGen"]="Lokale Musikgenerierung auf Basis von Meta Audiocraft / MusicGen."
TOOLS["Riffusion"]="Experimenteller Audio-Generierungsbaustein im Stil von Riffusion."
TOOLS["ControlNet"]="ControlNet-Helfer für konditionierte Bildpipelines."
TOOLS["Music2P_Pipeline"]="Workflow-Modul für musikgetriebene Prompt- und Clip-Pipelines."
TOOLS["Hook_Detection"]="Audioanalyse-Modul für Hook- und Highlight-Erkennung."
TOOLS["BPM_Analyzer"]="BPM-, Energy- und Tempo-Analysemodul für Audiotracks."
TOOLS["TikTok_Score"]="Heuristik-Modul für Viralitäts- und Kurzvideo-Scoring."
TOOLS["Emotion_Tagging"]="Tagging-Modul für Stimmung, Emotion und Tonalität in Audio- oder Textinhalten."
TOOLS["Docker"]="Docker Engine als Container-Laufzeit für Stacks, Integrationen und lokale Dienste."
TOOLS["Kubernetes"]="kubectl und Basisschicht für Kubernetes-nahe OpenClaw-Deployments."
TOOLS["K3s"]="Leichtgewichtige Kubernetes-Distribution für lokale oder VPS-nahe Cluster."
TOOLS["GitHub_API_Tooling"]="Python-Tooling für GitHub-API-Workflows, Repo-Automation und Metadatenabfragen."
TOOLS["Code_Sandbox"]="Lokal vorbereitetes Sandbox-Modul für isolierte Codeausführung."
TOOLS["VS_Code_Server"]="Code-Server für browserbasierte Entwicklungsumgebungen."
TOOLS["Puppeteer"]="Node-basierte Browserautomatisierung für Tests, Screenshots und Web-Workflows."
TOOLS["Aider"]="Terminal-Pair-Programming-Agent für Coding, Diffs, Refactoring und agentisches Arbeiten im Repository."
TOOLS["OpenCode"]="Offener Coding-Agent-Workspace mit Fokus auf Ollama- oder Provider-Anbindung für Codex-ähnliche Abläufe."
TOOLS["OpenHands"]="Agenten- und Sandbox-Workspace für größere Software-Engineering-Aufgaben mit stärkerer Automatisierung."
TOOLS["GitHub_CLI"]="GitHub CLI für Branches, Pull Requests, Actions und repo-nahe Entwicklerworkflows."
TOOLS["Podman"]="Daemonfreie Container-Laufzeit als Alternative oder Ergänzung zu Docker für lokale Sandboxes."
TOOLS["Unsloth"]="GitHub-basierter Fine-Tuning-Baustein für effizientes LoRA- und QLoRA-Training lokaler LLMs."
TOOLS["LLaMA_Factory"]="GitHub-basierter Trainings- und Evaluationsstack für Fine-Tuning, Adapterschichten und Modelltests."
TOOLS["Axolotl"]="GitHub-basierte Fine-Tuning-Toolchain für lokale LLM-Trainingsläufe und Adapter-Workflows."
TOOLS["Data_Juicer"]="GitHub-basierter Datensatz-Baustein für Bereinigung, Strukturierung und Qualitätskontrolle vor dem Fine-Tuning."
TOOLS["Llama_CPP_Toolchain"]="GitHub-basierte llama.cpp-Toolchain für GGUF-Export, Quantisierung und lokale Modelltests."
TOOLS["OpenTelemetry"]="Collector für Traces, Metrics und strukturierte Telemetrie."
TOOLS["Vault"]="Lokale Vault-Instanz für Secrets-Management und sichere Profileingaben."
TOOLS["SQLite"]="Leichtgewichtige Datenbank für lokale Agenten-, Workflow- und Testdaten."
TOOLS["Postgres"]="PostgreSQL für strukturierte Workflow-Daten, Integrationen und Agenten-Backends."
TOOLS["RabbitMQ"]="Message-Broker für Queue-basierte Agentenorchestrierung und Workflow-Entkopplung."
TOOLS["EULLM"]="Connector-Modul für europäische juristische LLM- oder Compliance-Workflows."
TOOLS["AI_Powered_Law_Firms"]="Connector-/Scaffold-Modul für AI Powered Law Firms Workflows."
TOOLS["Lawfirm"]="Rechtsfall- und Kanzlei-Workflow-Modul für Akten, Mandate und Entwürfe."
TOOLS["Tax_Law_Agent"]="Profilmodul für steuerrechtliche Fragestellungen, Recherche und Entwurfshilfen."
TOOLS["Risk_Agent"]="Agentenmodul für Risikoanalyse, Priorisierung und Warnhinweise."
TOOLS["Drafting_Agent"]="Entwurfs- und Redigiermodul für Texte, Schriftsätze und Vorlagen."
TOOLS["PDF_Parser"]="Dokumenten- und PDF-Parser für Legal-, Research- und Content-Workflows."
TOOLS["Neo4j"]="Graphdatenbank für Beziehungsanalysen, Wissensgraphen und Legal-/Research-Fälle."
TOOLS["Tax_Calculator"]="Scaffold-Modul für steuerliche Berechnungsvorlagen und Kontrollpunkte."
TOOLS["Deadline_Checker"]="Fristen- und Terminprüfmodul für juristische und operative Workflows."
TOOLS["Risk_Scoring"]="Scoring-Modul für Risiko, Priorität und Warnstufen in Agentenworkflows."
TOOLS["GitHub_Research"]="Workflow-Modul für GitHub-zentrierte Recherche, Repo-Screening und Änderungsbeobachtung."
TOOLS["Repo_Comparison"]="Vergleichsmodul für Repositories, Diffs, Features und Strukturähnlichkeiten."
TOOLS["Fail2Ban_Analyzer"]="Analysemodul für Fail2Ban-Logs, Trigger und Muster."
TOOLS["Security_Workflow"]="Workflow-Modul für Sicherheitschecks, Findings und Ticket-Übergaben."
TOOLS["Browser_Tool"]="Lokales Connector-Modul für Browser-gestützte Recherchen, QA und Navigation."
TOOLS["Firecrawl"]="Connector-Modul für Firecrawl- oder ähnliche Web-Scraping-Integrationen."
TOOLS["Google_Analytics_API"]="Connector-Modul für Google Analytics APIs."
TOOLS["Meta_Ads_API"]="Connector-Modul für Meta Ads Daten- und Kampagnenflows."
TOOLS["TikTok_Ads_API"]="Connector-Modul für TikTok Ads Kampagnen- und Performance-Daten."
TOOLS["File_System_Tool"]="Lokales Dateisystem-Modul für geordnete Asset-, Prompt- und Kampagnenordner."
TOOLS["HubSpot"]="Connector-Modul für HubSpot CRM- und Marketing-Automation."
TOOLS["Notion"]="Connector-Modul für Notion-Seiten, Datenbanken und Content-Backlogs."
TOOLS["Airtable"]="Connector-Modul für Airtable-Bases und Kampagnendaten."
TOOLS["Buffer_API"]="Connector-Modul für Buffer-basierte Scheduling- und Posting-Workflows."
TOOLS["Zapier"]="Connector-Modul für Zapier-Webhook- und Übergabepunkte."
TOOLS["Make"]="Connector-Modul für Make.com-Workflows und Webhook-Pfade."
TOOLS["Ahrefs"]="Connector-Modul für Ahrefs-SEO-Daten und Keyword-Workflows."
TOOLS["SEMrush"]="Connector-Modul für SEMrush SEO- und Wettbewerbsdaten."
TOOLS["ElevenLabs"]="Connector-Modul für ElevenLabs-TTS- oder Voice-Cloning-Workflows."
TOOLS["Zenbot_API"]="Integrationsmodul für Zenbot-nahe Strategien, Daten und Signale."
TOOLS["Risk_Strategy_Analyzer"]="Trading-Modul für Risiko- und Strategieauswertung."
TOOLS["Backtest_Workflow"]="Workflow-Modul für Backtests, Strategievarianten und Simulationsläufe."
TOOLS["AnimateDiff"]="Baustein für bewegte Diffusionssequenzen und visuelle Motion-Pipelines."
TOOLS["SVD"]="Scaffold für Stable Video Diffusion-nahe lokale Experimente."
TOOLS["Runway_API"]="Connector-Modul für Runway-nahe Visual- und Videoworkflows."
TOOLS["Image_Upscaler_Pipeline"]="Workflow-Modul für Upscaling, Nachschärfen und Asset-Finalisierung."
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
TOOL_SCRIPT_NAMES["Piper"]="piper"
TOOL_SCRIPT_NAMES["Coqui_TTS"]="coqui_tts"
TOOL_SCRIPT_NAMES["YT_DLP"]="yt_dlp"
TOOL_SCRIPT_NAMES["Web3_APIs"]="web3_apis"
TOOL_SCRIPT_NAMES["Exchange_APIs"]="exchange_apis"
TOOL_SCRIPT_NAMES["Nmap"]="nmap"
TOOL_SCRIPT_NAMES["Nikto"]="nikto"
TOOL_SCRIPT_NAMES["Trivy"]="trivy"
TOOL_SCRIPT_NAMES["Fail2Ban"]="fail2ban"
TOOL_SCRIPT_NAMES["Stable_Diffusion_WebUI"]="stable_diffusion_webui"
TOOL_SCRIPT_NAMES["ComfyUI"]="comfyui"
TOOL_SCRIPT_NAMES["RealESRGAN"]="realesrgan"
TOOL_SCRIPT_NAMES["Redis"]="redis"
TOOL_SCRIPT_NAMES["NATS"]="nats"
TOOL_SCRIPT_NAMES["Qdrant"]="qdrant"
TOOL_SCRIPT_NAMES["Weaviate"]="weaviate"
TOOL_SCRIPT_NAMES["Prometheus"]="prometheus"
TOOL_SCRIPT_NAMES["Grafana"]="grafana"
TOOL_SCRIPT_NAMES["Loki"]="loki"
TOOL_SCRIPT_NAMES["Trend_Monitor"]="trend_monitor"
TOOL_SCRIPT_NAMES["Agent_Router"]="agent_router"
TOOL_SCRIPT_NAMES["Memory_Policies"]="memory_policies"
TOOL_SCRIPT_NAMES["Voice_Assistant_Runtime"]="voice_assistant_runtime"
TOOL_SCRIPT_NAMES["Thumbnail_Pipeline"]="thumbnail_pipeline"
TOOL_SCRIPT_NAMES["Upload_Automation"]="upload_automation"
TOOL_SCRIPT_NAMES["Weights_and_Biases"]="weights_and_biases"
TOOL_SCRIPT_NAMES["vLLM"]="vllm"
TOOL_SCRIPT_NAMES["Llama_CPP"]="llama_cpp"
TOOL_SCRIPT_NAMES["Ray"]="ray"
TOOL_SCRIPT_NAMES["EnviroLLM"]="envirollm"
TOOL_SCRIPT_NAMES["Suno_API"]="suno_api"
TOOL_SCRIPT_NAMES["Udio_API"]="udio_api"
TOOL_SCRIPT_NAMES["MusicGen"]="musicgen"
TOOL_SCRIPT_NAMES["Riffusion"]="riffusion"
TOOL_SCRIPT_NAMES["ControlNet"]="controlnet"
TOOL_SCRIPT_NAMES["Music2P_Pipeline"]="music2p_pipeline"
TOOL_SCRIPT_NAMES["Hook_Detection"]="hook_detection"
TOOL_SCRIPT_NAMES["BPM_Analyzer"]="bpm_analyzer"
TOOL_SCRIPT_NAMES["TikTok_Score"]="tiktok_score"
TOOL_SCRIPT_NAMES["Emotion_Tagging"]="emotion_tagging"
TOOL_SCRIPT_NAMES["Docker"]="docker"
TOOL_SCRIPT_NAMES["Kubernetes"]="kubernetes"
TOOL_SCRIPT_NAMES["K3s"]="k3s"
TOOL_SCRIPT_NAMES["GitHub_API_Tooling"]="github_api_tooling"
TOOL_SCRIPT_NAMES["Code_Sandbox"]="code_sandbox"
TOOL_SCRIPT_NAMES["VS_Code_Server"]="vs_code_server"
TOOL_SCRIPT_NAMES["Puppeteer"]="puppeteer"
TOOL_SCRIPT_NAMES["Aider"]="aider"
TOOL_SCRIPT_NAMES["OpenCode"]="opencode"
TOOL_SCRIPT_NAMES["OpenHands"]="openhands"
TOOL_SCRIPT_NAMES["GitHub_CLI"]="github_cli"
TOOL_SCRIPT_NAMES["Podman"]="podman"
TOOL_SCRIPT_NAMES["Unsloth"]="unsloth"
TOOL_SCRIPT_NAMES["LLaMA_Factory"]="llama_factory"
TOOL_SCRIPT_NAMES["Axolotl"]="axolotl"
TOOL_SCRIPT_NAMES["Data_Juicer"]="data_juicer"
TOOL_SCRIPT_NAMES["Llama_CPP_Toolchain"]="llama_cpp_toolchain"
TOOL_SCRIPT_NAMES["OpenTelemetry"]="opentelemetry"
TOOL_SCRIPT_NAMES["Vault"]="vault"
TOOL_SCRIPT_NAMES["SQLite"]="sqlite"
TOOL_SCRIPT_NAMES["Postgres"]="postgres"
TOOL_SCRIPT_NAMES["RabbitMQ"]="rabbitmq"
TOOL_SCRIPT_NAMES["EULLM"]="eullm"
TOOL_SCRIPT_NAMES["AI_Powered_Law_Firms"]="ai_powered_law_firms"
TOOL_SCRIPT_NAMES["Lawfirm"]="lawfirm"
TOOL_SCRIPT_NAMES["Tax_Law_Agent"]="tax_law_agent"
TOOL_SCRIPT_NAMES["Risk_Agent"]="risk_agent"
TOOL_SCRIPT_NAMES["Drafting_Agent"]="drafting_agent"
TOOL_SCRIPT_NAMES["PDF_Parser"]="pdf_parser"
TOOL_SCRIPT_NAMES["Neo4j"]="neo4j"
TOOL_SCRIPT_NAMES["Tax_Calculator"]="tax_calculator"
TOOL_SCRIPT_NAMES["Deadline_Checker"]="deadline_checker"
TOOL_SCRIPT_NAMES["Risk_Scoring"]="risk_scoring"
TOOL_SCRIPT_NAMES["GitHub_Research"]="github_research"
TOOL_SCRIPT_NAMES["Repo_Comparison"]="repo_comparison"
TOOL_SCRIPT_NAMES["Fail2Ban_Analyzer"]="fail2ban_analyzer"
TOOL_SCRIPT_NAMES["Security_Workflow"]="security_workflow"
TOOL_SCRIPT_NAMES["Browser_Tool"]="browser_tool"
TOOL_SCRIPT_NAMES["Firecrawl"]="firecrawl"
TOOL_SCRIPT_NAMES["Google_Analytics_API"]="google_analytics_api"
TOOL_SCRIPT_NAMES["Meta_Ads_API"]="meta_ads_api"
TOOL_SCRIPT_NAMES["TikTok_Ads_API"]="tiktok_ads_api"
TOOL_SCRIPT_NAMES["File_System_Tool"]="file_system_tool"
TOOL_SCRIPT_NAMES["HubSpot"]="hubspot"
TOOL_SCRIPT_NAMES["Notion"]="notion"
TOOL_SCRIPT_NAMES["Airtable"]="airtable"
TOOL_SCRIPT_NAMES["Buffer_API"]="buffer_api"
TOOL_SCRIPT_NAMES["Zapier"]="zapier"
TOOL_SCRIPT_NAMES["Make"]="make_automation"
TOOL_SCRIPT_NAMES["Ahrefs"]="ahrefs"
TOOL_SCRIPT_NAMES["SEMrush"]="semrush"
TOOL_SCRIPT_NAMES["ElevenLabs"]="elevenlabs"
TOOL_SCRIPT_NAMES["Zenbot_API"]="zenbot_api"
TOOL_SCRIPT_NAMES["Risk_Strategy_Analyzer"]="risk_strategy_analyzer"
TOOL_SCRIPT_NAMES["Backtest_Workflow"]="backtest_workflow"
TOOL_SCRIPT_NAMES["AnimateDiff"]="animatediff"
TOOL_SCRIPT_NAMES["SVD"]="svd"
TOOL_SCRIPT_NAMES["Runway_API"]="runway_api"
TOOL_SCRIPT_NAMES["Image_Upscaler_Pipeline"]="image_upscaler_pipeline"

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
    show_tool_action_intro "$TOOL_KEY" "installieren"
    begin_operation_measurement "tool_install_${TOOL_KEY}" "Tool installieren: ${TOOL_KEY}"
    echo -e "${BLUE}Installiere Tool: ${TOOL_KEY}...${NC}"
    run_tool_script "$TOOL_KEY" "install"
    if [ $? -eq 0 ]; then
        append_unique_line "$TOOL_STATUS_FILE" "$TOOL_KEY"
        end_operation_measurement "success"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich installiert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Installation von Tool \'$TOOL_KEY\'.${NC}"
    fi
}

# Funktion zum Deinstallieren eines Tools
uninstall_tool() {
    local TOOL_KEY="$1"
    show_tool_action_intro "$TOOL_KEY" "deinstallieren"
    begin_operation_measurement "tool_uninstall_${TOOL_KEY}" "Tool deinstallieren: ${TOOL_KEY}"
    echo -e "${BLUE}Deinstalliere Tool: ${TOOL_KEY}...${NC}"
    run_tool_script "$TOOL_KEY" "uninstall"
    if [ $? -eq 0 ]; then
        remove_exact_line "$TOOL_STATUS_FILE" "$TOOL_KEY"
        end_operation_measurement "success"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich deinstalliert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Deinstallation von Tool \'$TOOL_KEY\'.${NC}"
    fi
}

# Funktion zum Anzeigen des Tool-Management-Menüs
show_tool_management_menu() {
    sync_core_tool_status
    ensure_user_workspace
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"

    # Installierte Tools laden
    declare -A INSTALLED_TOOLS_MAP
    load_installed_map "$TOOL_STATUS_FILE" INSTALLED_TOOLS_MAP

    TOOL_CHECKLIST_OPTIONS=()
    for tool_key in "${TOOL_KEYS[@]}"; do
        STATUS="off"
        if [ -n "$tool_key" ] && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" = "1" ]; then
            STATUS="on"
        fi
        TOOL_CHECKLIST_OPTIONS+=("$tool_key" "${TOOLS[$tool_key]}" "$STATUS")
    done

    dialog --clear --backtitle "$APP_TITLE" \
    --title "TOOL-MANAGEMENT" --checklist "Wählen Sie Tools zum Installieren/Deinstallieren:" 32 110 24 \
    "${TOOL_CHECKLIST_OPTIONS[@]}" 2> /tmp/tool_selection

    if [ $? -ne 0 ]; then
        return 0
    fi

    mapfile -t SELECTED_TOOLS_ARRAY < <(tr ' ' '\n' < /tmp/tool_selection | tr -d '"' | sed '/^$/d')

    # Installation/Deinstallation basierend auf Auswahl
    for tool_key in "${TOOL_KEYS[@]}"; do
        if selection_contains "$tool_key" "${SELECTED_TOOLS_ARRAY[@]}" && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" != "1" ]; then
            # Tool ausgewählt und nicht installiert -> Installieren
            install_tool "$tool_key"
        elif ! selection_contains "$tool_key" "${SELECTED_TOOLS_ARRAY[@]}" && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" = "1" ]; then
            # Tool nicht ausgewählt und installiert -> Deinstallieren
            uninstall_tool "$tool_key"
        fi
    done
    read -p "Tool-Management abgeschlossen. Drücken Sie Enter..."
}

declare -A PROFILE_CORE_TOOLS
declare -A PROFILE_EXTENDED_TOOLS
declare -A PROFILE_INTEGRATION_TOOLS
declare -A PROFILE_SPECIAL_TOOLS
declare -A PROFILE_SPECIAL_LABELS

PROFILE_CORE_TOOLS["Programmierer"]="Huginn Clawhub_CLI LangGraph CrewAI AutoGen Playwright ChromaDB Code_Sandbox"
PROFILE_EXTENDED_TOOLS["Programmierer"]="GitHub_API_Tooling VS_Code_Server Puppeteer SQLite Postgres"
PROFILE_INTEGRATION_TOOLS["Programmierer"]="Docker Kubernetes K3s Prometheus Grafana Loki OpenTelemetry Vault Weaviate Qdrant Redis RabbitMQ NATS"
PROFILE_SPECIAL_TOOLS["Programmierer"]="Aider OpenCode OpenHands GitHub_CLI Podman Docker K3s Clawbake Ollama"
PROFILE_SPECIAL_LABELS["Programmierer"]="Codex-Nachbau"

PROFILE_CORE_TOOLS["Media_Musik"]="Clawbake FFmpeg librosa pydub Demucs Whisper"
PROFILE_EXTENDED_TOOLS["Media_Musik"]="MusicGen Riffusion ControlNet Hook_Detection BPM_Analyzer Emotion_Tagging"
PROFILE_INTEGRATION_TOOLS["Media_Musik"]="Suno_API Udio_API Music2P_Pipeline TikTok_Score Stable_Diffusion_WebUI"

PROFILE_CORE_TOOLS["KI_Forschung"]="OpenClaw_RL Flowise LangFlow LangChain LlamaIndex MLflow Whisper"
PROFILE_EXTENDED_TOOLS["KI_Forschung"]="ChromaDB Weaviate CrewAI AutoGPT Weights_and_Biases vLLM Llama_CPP Ray EnviroLLM"
PROFILE_INTEGRATION_TOOLS["KI_Forschung"]="Stable_Diffusion_WebUI"

PROFILE_CORE_TOOLS["Texter_Werbung_Marketing"]="n8n Activepieces LangChain ChromaDB Playwright"
PROFILE_EXTENDED_TOOLS["Texter_Werbung_Marketing"]="Browser_Tool Firecrawl File_System_Tool Weaviate Qdrant Stable_Diffusion_WebUI"
PROFILE_INTEGRATION_TOOLS["Texter_Werbung_Marketing"]="Google_Analytics_API Meta_Ads_API TikTok_Ads_API HubSpot Notion Airtable Buffer_API Zapier Make Ahrefs SEMrush ElevenLabs"

PROFILE_CORE_TOOLS["Rechtsberatung_Steuerrecht"]="Zotero LangChain LlamaIndex ChromaDB PDF_Parser Qdrant"
PROFILE_EXTENDED_TOOLS["Rechtsberatung_Steuerrecht"]="EULLM Neo4j Tax_Calculator Deadline_Checker Risk_Scoring"
PROFILE_INTEGRATION_TOOLS["Rechtsberatung_Steuerrecht"]="AI_Powered_Law_Firms Lawfirm Tax_Law_Agent Risk_Agent Drafting_Agent"

PROFILE_CORE_TOOLS["Agent_Orchestrator"]="LangGraph CrewAI AutoGen Agent_Router Memory_Policies"
PROFILE_EXTENDED_TOOLS["Agent_Orchestrator"]="ChromaDB Redis NATS Qdrant Weaviate"
PROFILE_INTEGRATION_TOOLS["Agent_Orchestrator"]="Prometheus Grafana Loki"

PROFILE_CORE_TOOLS["Audio"]="Whisper FFmpeg Piper Coqui_TTS librosa pydub"
PROFILE_EXTENDED_TOOLS["Audio"]="Voice_Assistant_Runtime"
PROFILE_INTEGRATION_TOOLS["Audio"]=""

PROFILE_CORE_TOOLS["Content_Automation"]="FFmpeg Whisper Playwright n8n Activepieces YT_DLP"
PROFILE_EXTENDED_TOOLS["Content_Automation"]="Piper Coqui_TTS Stable_Diffusion_WebUI Trend_Monitor Thumbnail_Pipeline Upload_Automation"
PROFILE_INTEGRATION_TOOLS["Content_Automation"]=""

PROFILE_CORE_TOOLS["Research_Agent"]="Playwright LangChain LlamaIndex ChromaDB Trend_Monitor GitHub_Research Repo_Comparison"
PROFILE_EXTENDED_TOOLS["Research_Agent"]="Qdrant Weaviate"
PROFILE_INTEGRATION_TOOLS["Research_Agent"]=""

PROFILE_CORE_TOOLS["Security_Analyst"]="Nmap Nikto Trivy Fail2Ban"
PROFILE_EXTENDED_TOOLS["Security_Analyst"]="Fail2Ban_Analyzer Security_Workflow"
PROFILE_INTEGRATION_TOOLS["Security_Analyst"]=""

PROFILE_CORE_TOOLS["Trading_AI"]="Zenbot_trader Web3_APIs Exchange_APIs"
PROFILE_EXTENDED_TOOLS["Trading_AI"]="Zenbot_API Risk_Strategy_Analyzer Backtest_Workflow"
PROFILE_INTEGRATION_TOOLS["Trading_AI"]=""

PROFILE_CORE_TOOLS["Visual_Creator"]="FFmpeg Stable_Diffusion_WebUI ComfyUI RealESRGAN"
PROFILE_EXTENDED_TOOLS["Visual_Creator"]="AnimateDiff SVD Runway_API Image_Upscaler_Pipeline"
PROFILE_INTEGRATION_TOOLS["Visual_Creator"]=""

PROFILE_CORE_TOOLS["LLM_Builder"]="Ollama Data_Juicer Unsloth LLaMA_Factory Llama_CPP_Toolchain"
PROFILE_EXTENDED_TOOLS["LLM_Builder"]="Axolotl MLflow Weights_and_Biases vLLM Llama_CPP"
PROFILE_INTEGRATION_TOOLS["LLM_Builder"]="OpenClaw Flowise LangFlow Huginn Clawbake Docker Code_Sandbox GitHub_CLI ChromaDB"
PROFILE_SPECIAL_TOOLS["LLM_Builder"]="Ollama Data_Juicer Unsloth LLaMA_Factory Llama_CPP_Toolchain Axolotl MLflow Weights_and_Biases vLLM Llama_CPP OpenClaw Flowise LangFlow Huginn Clawbake Docker Code_Sandbox GitHub_CLI ChromaDB"
PROFILE_SPECIAL_LABELS["LLM_Builder"]="LLM-Builder komplett"

show_tool_group_checklist() {
    local group_title="$1"
    local tool_list="$2"
    local options=()
    local tool_key
    local status
    declare -A installed_map

    ensure_user_workspace
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"
    load_installed_map "$TOOL_STATUS_FILE" installed_map

    for tool_key in $tool_list; do
        [ -n "$tool_key" ] || continue
        status="off"
        if [ "${installed_map[$tool_key]:-}" = "1" ]; then
            status="on"
        fi
        options+=("$tool_key" "${TOOLS[$tool_key]}" "$status")
    done

    if [ ${#options[@]} -eq 0 ]; then
        dialog --msgbox "${TXT_NO_TOOLS_DEFINED:-Für diesen Block sind aktuell keine Einzeltools definiert.}" 8 60
        return 0
    fi

    dialog --clear --backtitle "$APP_TITLE" \
    --title "$group_title" --checklist "Wählen Sie Tools zum Installieren/Deinstallieren:" 28 110 18 \
    "${options[@]}" 2> /tmp/profile_block_tools_selection

    if [ $? -ne 0 ]; then
        return 0
    fi

    mapfile -t SELECTED_GROUP_TOOLS < <(tr ' ' '\n' < /tmp/profile_block_tools_selection | tr -d '"' | sed '/^$/d')

    for tool_key in $tool_list; do
        [ -n "$tool_key" ] || continue
        if selection_contains "$tool_key" "${SELECTED_GROUP_TOOLS[@]}" && [ "${installed_map[$tool_key]:-}" != "1" ]; then
            install_tool "$tool_key"
        elif ! selection_contains "$tool_key" "${SELECTED_GROUP_TOOLS[@]}" && [ "${installed_map[$tool_key]:-}" = "1" ]; then
            uninstall_tool "$tool_key"
        fi
    done
}

toggle_full_profile_from_block() {
    local profile_key="$1"
    declare -A installed_profiles_map

    ensure_user_workspace
    normalize_status_file "$PROFILE_STATUS_FILE" "${PROFILE_KEYS[@]}"
    load_installed_map "$PROFILE_STATUS_FILE" installed_profiles_map

    if [ "${installed_profiles_map[$profile_key]:-}" = "1" ]; then
        dialog --yesno "Profil '$profile_key' ist aktuell installiert. Möchten Sie das gesamte Profil jetzt deinstallieren?" 8 80
        if [ $? -eq 0 ]; then
            uninstall_profile "$profile_key"
        fi
    else
        dialog --yesno "Profil '$profile_key' ist aktuell nicht installiert. Möchten Sie das gesamte Profil jetzt installieren?" 8 80
        if [ $? -eq 0 ]; then
            install_profile "$profile_key"
        fi
    fi
}

toggle_tool_group_bulk() {
    local group_title="$1"
    local tool_list="$2"
    local tool_key
    local all_installed=1
    local has_tools=0
    declare -A installed_map

    ensure_user_workspace
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"
    load_installed_map "$TOOL_STATUS_FILE" installed_map

    for tool_key in $tool_list; do
        [ -n "$tool_key" ] || continue
        has_tools=1
        if [ "${installed_map[$tool_key]:-}" != "1" ]; then
            all_installed=0
        fi
    done

    if [ "$has_tools" -eq 0 ]; then
        dialog --msgbox "Für diesen Block sind aktuell keine Tools definiert." 8 60
        return 0
    fi

    if [ "$all_installed" -eq 1 ]; then
        dialog --yesno "Block '$group_title' ist aktuell installiert. Möchten Sie alle enthaltenen Tools jetzt deinstallieren?" 9 90
        if [ $? -eq 0 ]; then
            for tool_key in $tool_list; do
                [ -n "$tool_key" ] || continue
                uninstall_tool "$tool_key"
            done
        fi
    else
        dialog --yesno "Block '$group_title' ist aktuell nicht vollständig installiert. Möchten Sie alle enthaltenen Tools jetzt installieren?" 9 95
        if [ $? -eq 0 ]; then
            for tool_key in $tool_list; do
                [ -n "$tool_key" ] || continue
                install_tool "$tool_key"
            done
        fi
    fi
}

show_profile_block_detail_menu() {
    local profile_key="$1"
    local choice
    local has_special_tools=0
    local special_label="Spezialblock"

    if [ -n "${PROFILE_SPECIAL_TOOLS[$profile_key]:-}" ]; then
        has_special_tools=1
    fi
    if [ -n "${PROFILE_SPECIAL_LABELS[$profile_key]:-}" ]; then
        special_label="${PROFILE_SPECIAL_LABELS[$profile_key]}"
    fi

    while true; do
        if [ "$has_special_tools" -eq 1 ]; then
            dialog --clear --backtitle "$APP_TITLE" \
            --title "PROFILBLOCK: $profile_key" --menu "Wählen Sie Block oder Gesamtprofil:" 24 96 10 \
            "1" "Gesamtes Profil installieren/deinstallieren" \
            "2" "Kernmodule (wichtig)" \
            "3" "Erweiterte Module" \
            "4" "Integrationen / Optional" \
            "5" "${special_label} (Einzeltools)" \
            "6" "${special_label} komplett installieren/deinstallieren" \
            "7" "Zurück" 2> /tmp/profile_block_choice
        else
            dialog --clear --backtitle "$APP_TITLE" \
            --title "PROFILBLOCK: $profile_key" --menu "Wählen Sie Block oder Gesamtprofil:" 22 90 8 \
            "1" "Gesamtes Profil installieren/deinstallieren" \
            "2" "Kernmodule (wichtig)" \
            "3" "Erweiterte Module" \
            "4" "Integrationen / Optional" \
            "5" "Zurück" 2> /tmp/profile_block_choice
        fi

        if [ $? -ne 0 ]; then
            return 0
        fi

        choice="$(cat /tmp/profile_block_choice)"
        case "$choice" in
            1) toggle_full_profile_from_block "$profile_key" ;;
            2) show_tool_group_checklist "$profile_key - Kernmodule" "${PROFILE_CORE_TOOLS[$profile_key]}" ;;
            3) show_tool_group_checklist "$profile_key - Erweiterte Module" "${PROFILE_EXTENDED_TOOLS[$profile_key]}" ;;
            4) show_tool_group_checklist "$profile_key - Integrationen / Optional" "${PROFILE_INTEGRATION_TOOLS[$profile_key]}" ;;
            5)
                if [ "$has_special_tools" -eq 1 ]; then
                    show_tool_group_checklist "$profile_key - ${special_label}" "${PROFILE_SPECIAL_TOOLS[$profile_key]}"
                else
                    return 0
                fi
                ;;
            6)
                if [ "$has_special_tools" -eq 1 ]; then
                    toggle_tool_group_bulk "$profile_key - ${special_label}" "${PROFILE_SPECIAL_TOOLS[$profile_key]}"
                else
                    return 0
                fi
                ;;
            7) return 0 ;;
        esac
    done
}

show_profile_block_browser() {
    local options=()
    local profile_key

    for profile_key in "${PROFILE_KEYS[@]}"; do
        options+=("$profile_key" "${PROFILES[$profile_key]}")
    done

    dialog --clear --backtitle "$APP_TITLE" \
    --title "PROFILBLÖCKE & EINZELTOOLS" --menu "Wählen Sie einen Profilblock aus:" 26 100 14 \
    "${options[@]}" 2> /tmp/profile_block_profile_choice

    if [ $? -ne 0 ]; then
        return 0
    fi

    show_profile_block_detail_menu "$(cat /tmp/profile_block_profile_choice)"
}

show_profile_management_hub() {
    dialog --clear --backtitle "$APP_TITLE" \
    --title "PROFIL-MANAGEMENT" --menu "Wählen Sie eine Ansicht:" 18 90 6 \
    "1" "Schnellansicht: komplette Profile" \
    "2" "Blockansicht: Profilblöcke + Einzeltools" \
    "3" "Zurück" 2> /tmp/profile_management_hub_choice

    if [ $? -ne 0 ]; then
        return 0
    fi

    case "$(cat /tmp/profile_management_hub_choice)" in
        1) show_profile_management_menu ;;
        2) show_profile_block_browser ;;
        3) return 0 ;;
    esac
}

# --- Hauptmenü --- 

show_main_menu() {
    local dialog_rc
    local menu_height=23
    local menu_width=88
    local menu_rows=17
    local term_lines=0
    local term_cols=0
    local begin_row=1
    local begin_col=1

    : > /tmp/menu_choice
    reset_terminal_display
    if command -v tput >/dev/null 2>&1; then
        term_lines="$(tput lines 2>/dev/null || echo 0)"
        term_cols="$(tput cols 2>/dev/null || echo 0)"
        if [ "$term_lines" -gt "$menu_height" ]; then
            begin_row=$(( (term_lines - menu_height) / 2 + 1 ))
        fi
        if [ "$term_cols" -gt "$menu_width" ]; then
            begin_col=$(( (term_cols - menu_width) / 2 ))
        fi
    fi

    dialog --clear --backtitle "$APP_TITLE" \
    --begin "$begin_row" "$begin_col" \
    --ok-label "${TXT_OK_LABEL:-✔  OK}" \
    --cancel-label "${TXT_CANCEL_LABEL:-🚪 Beenden}" \
    --extra-button --extra-label "${TXT_OPTIONS_BUTTON:-⚙  Optionen}" \
    --title "${TXT_MENU_TITLE:-HAUPTMENÜ}" --menu "${TXT_MENU_PROMPT:-Wählen Sie Ihr Ziel-System oder eine Aktion:}" "$menu_height" "$menu_width" "$menu_rows" \
    "1" "${TXT_MENU_1:-Setup-Update + System-Update (Repo, OS & pnpm)}" \
    "2" "${TXT_MENU_2:-Ollama Modell-Manager}" \
    "3" "${TXT_MENU_3:-OpenClaw Konfiguration (.env & config.json)}" \
    "4" "${TXT_MENU_4:-Hybrid: Letsung MiniPC + Multi-VPS (Empfohlen)}" \
    "5" "${TXT_MENU_5:-Standalone: Nur VPS (Cloud-Native)}" \
    "6" "${TXT_MENU_6:-Standalone: Nur MiniPC (Lokal)}" \
    "─" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
    "7" "${TXT_MENU_7:-Ruflo: Installation & Management}" \
    "──" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
    "8" "${TXT_MENU_8:-Tools: Installieren & Deinstallieren}" \
    "9" "${TXT_MENU_9:-Profile: Blöcke, Gesamtprofile & Einzeltools}" \
    "───" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
    "10" "${TXT_MENU_10:-Dokumentation & API-Key Guide}" \
    "11" "${TXT_MENU_11:-System-Check & Port-Analyse}" \
    "12" "${TXT_MENU_12:-OpenClaw starten (Dev-Modus)}" \
    "13" "${TXT_MENU_13:-Home Assistant starten}" 2> /tmp/menu_choice

    dialog_rc=$?
    if [ $dialog_rc -eq 3 ]; then
        printf '%s\n' "OPTIONS" > /tmp/menu_choice
    elif [ $dialog_rc -ne 0 ]; then
        printf '%s\n' "17" > /tmp/menu_choice
    fi

    return 0
}

# Hauptschleife
while true; do
    if [ "$LANGUAGE_SELECTION_REQUIRED" = "1" ]; then
        show_setup_language_menu || true
        LANGUAGE_SELECTION_REQUIRED=0
    fi
    show_main_menu
    if [ -s /tmp/menu_choice ]; then
        CHOICE="$(tr -d '[:space:]' < /tmp/menu_choice)"
    else
        CHOICE="17"
    fi

    if [ "$CHOICE" = "17" ]; then
        print_exit_message
        exit 0
    fi
    
    case $CHOICE in
        OPTIONS)
            show_options_menu
            ;;
        1)
            show_operation_intro \
            "Setup-Update + System-Update" \
            "Das Setup-Repository wird aktualisiert. Danach folgen Ubuntu-Updates sowie die Aktualisierung von pnpm." \
            "${UBUNTU_UPDATES_DOWNLOAD_TIME_ESTIMATE} Download + ${UBUNTU_UPDATES_INSTALL_TIME_ESTIMATE} Installation" \
            "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB" \
            "Bei lokalen Aenderungen im Setup wird das Repo-Update bewusst uebersprungen, damit nichts ueberschrieben wird."
            begin_operation_measurement "main_menu_update" "Setup-Update + System-Update"
            run_bash_script "$INSTALL_DIR/scripts/auto_update.sh"
            if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
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
            show_operation_intro \
            "Hybrid-Setup: Letsung MiniPC + Multi-VPS" \
            "Installiert zuerst die Basis mit OpenClaw und Ollama und richtet danach das hybride Setup mit Home Assistant und Cloudflare-nahem Zugriff ein." \
            "${SETUP_INSTALL_TIME_ESTIMATE} Gesamt, darin meist ${OPENCLAW_DOWNLOAD_TIME_ESTIMATE} Download + ${OPENCLAW_BUILD_TIME_ESTIMATE} Build + ${OLLAMA_INSTALL_TIME_ESTIMATE} fuer Ollama + ${HOME_ASSISTANT_INSTALL_TIME_ESTIMATE} fuer Home Assistant" \
            "${MIN_FREE_GB_RECOMMENDED} GB oder mehr" \
            "Je nach Cloudflare- und VPS-Schritten koennen weitere manuelle Angaben oder API-Daten noetig sein."
            begin_operation_measurement "main_menu_hybrid" "Hybrid-Setup: Letsung MiniPC + Multi-VPS"
            echo -e "${BLUE}Starte Hybrid-Setup (Letsung MiniPC + Multi-VPS)...${NC}"
            if run_base_install_if_needed; then
                run_bash_script "$INSTALL_DIR/scripts/hybrid_setup.sh"
                if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            else
                end_operation_measurement "failed"
                echo -e "${RED}Hybrid-Setup abgebrochen, weil die Basis-Installation fehlgeschlagen ist.${NC}"
            fi
            read -p "Hybrid-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        5)
            show_operation_intro \
            "Standalone-Setup: Nur VPS (Cloud-Native)" \
            "Installiert die Basis und richtet danach die VPS-Variante mit K3s-/Cloud-Native-Bausteinen fuer OpenClaw vor." \
            "${SETUP_INSTALL_TIME_ESTIMATE} Gesamt, darin meist ${OPENCLAW_DOWNLOAD_TIME_ESTIMATE} Download + ${OPENCLAW_BUILD_TIME_ESTIMATE} Build + ${OLLAMA_INSTALL_TIME_ESTIMATE} fuer Ollama" \
            "${MIN_FREE_GB_RECOMMENDED} GB oder mehr" \
            "Einige Teile sind vorbereitende Infrastruktur. Fuer produktive Deployments koennen spaeter noch weitere Schritte notwendig sein."
            begin_operation_measurement "main_menu_vps" "Standalone-Setup: Nur VPS"
            echo -e "${BLUE}Starte Standalone VPS-Setup (Cloud-Native)...${NC}"
            if run_base_install_if_needed; then
                run_bash_script "$INSTALL_DIR/scripts/vps_standalone.sh"
                if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            else
                end_operation_measurement "failed"
                echo -e "${RED}VPS-Standalone-Setup abgebrochen, weil die Basis-Installation fehlgeschlagen ist.${NC}"
            fi
            read -p "VPS-Standalone-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        6)
            load_metrics_config
            show_operation_intro \
            "Standalone-Setup: Nur MiniPC (Lokal)" \
            "Installiert die komplette lokale Basis mit OpenClaw, Ollama und den fuer den MiniPC vorgesehenen Zusatzkomponenten." \
            "${LOCAL_SETUP_TOTAL_ESTIMATE} Gesamt, darin meist ${OPENCLAW_DOWNLOAD_TIME_ESTIMATE} Download + ${OPENCLAW_BUILD_TIME_ESTIMATE} Build + ${OLLAMA_INSTALL_TIME_ESTIMATE} fuer Ollama + ${HOME_ASSISTANT_INSTALL_TIME_ESTIMATE} fuer Home Assistant" \
            "${MIN_FREE_GB_RECOMMENDED} GB oder mehr" \
            "Der OpenClaw-Build mit Ollama kann geschaetzt ${LOCAL_SETUP_TOTAL_ESTIMATE} dauern.\nEine Eingabe des Ubuntu-Passworts wird kurz nach Beginn der Installation abverlangt.\nIn voraussichtlich ${RED}${LOCAL_SETUP_CONFIRM_STOP_1_ESTIMATE}${YELLOW} wird eine manuelle Bestaetigung von dir verlangt, typischerweise beim nachtraeglichen Build von @discordjs/opus.\nDanach geht es auch schon mit Ollama weiter, grob ab ${RED}${LOCAL_SETUP_CONFIRM_STOP_2_ESTIMATE}${YELLOW}, inklusive einer erneuten Ubuntu-Passwortabfrage.\nKurz vor ${RED}${LOCAL_SETUP_CLOUDFLARE_TOKEN_STOP_ESTIMATE}${YELLOW} wird in der Regel der Cloudflare-Token abgefragt.\nDiese Zwischenstopps gehoeren zur gesamten Zeitmessung mit dazu."
            begin_operation_measurement "main_menu_local" "Standalone-Setup: Nur MiniPC"
            echo -e "${BLUE}Starte Standalone MiniPC-Setup (Lokal)...${NC}"
            if run_base_install_if_needed; then
                run_bash_script "$INSTALL_DIR/scripts/install_local_only.sh"
                if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            else
                end_operation_measurement "failed"
                echo -e "${RED}Standalone MiniPC-Setup abgebrochen, weil die Basis-Installation fehlgeschlagen ist.${NC}"
            fi
            read -p "Standalone MiniPC-Setup abgeschlossen. Drücken Sie Enter..."
            ;;
        "─"|"──"|"───"|"────")
            continue
            ;;
        7)
            show_operation_intro \
            "Ruflo: Installation & Management" \
            "Klonen, Node.js-/pnpm-Pruefung, Build und CLI-Verknuepfung fuer Ruflo bzw. Claude-Flow-nahe Werkzeuge." \
            "${SETUP_DOWNLOAD_TIME_ESTIMATE} Download + ${SETUP_INSTALL_TIME_ESTIMATE} Installation" \
            "${MIN_FREE_GB_ABSOLUTE} GB oder mehr" \
            "Abhaengig vom Repo-Ziel kann zusaetzlich Netzwerkzeit fuer das Klonen und den Build anfallen."
            begin_operation_measurement "main_menu_ruflo" "Ruflo: Installation & Management"
            echo -e "${BLUE}Ruflo Installation & Management...${NC}"
            run_bash_script "$INSTALL_DIR/scripts/ruflo_install.sh"
            if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            read -p "Ruflo-Aktion abgeschlossen. Drücken Sie Enter..."
            ;;
        8)
            show_tool_management_menu
            ;;
        9)
            show_profile_management_hub
            ;;
        10)
            dialog --clear --backtitle "$APP_TITLE" \
            --title "Dokumentation & API-Key Guide" --textbox "$INSTALL_DIR/docs/API_KEY_GUIDE.md" 25 80
            ;;
        11)
            run_bash_script "$INSTALL_DIR/scripts/port_check.sh"
            read -p "Port-Analyse abgeschlossen. Drücken Sie Enter..."
            ;;
        12)
            show_operation_intro \
            "OpenClaw im Dev-Modus starten" \
            "Startet die vorhandene OpenClaw-Installation im Entwicklungsmodus mit pnpm dev." \
            "Start meist in wenigen Sekunden bis Minuten, je nach vorhandenem Build-Stand" \
            "${MIN_FREE_GB_ABSOLUTE} GB oder mehr" \
            "Falls die Basis noch nicht installiert ist, fuehre zuerst ein Setup wie Punkt 4, 5 oder 6 aus."
            begin_operation_measurement "main_menu_openclaw_dev" "OpenClaw im Dev-Modus starten"
            echo -e "${BLUE}Starte OpenClaw im Dev-Modus...${NC}"
            cd /opt/openclaw && pnpm dev
            if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            ;;
        13)
            show_operation_intro \
            "Home Assistant starten" \
            "Startet den vorhandenen Home-Assistant-Dienst ueber systemd." \
            "${HOME_ASSISTANT_INSTALL_TIME_ESTIMATE} fuer Erstaufbau, Start selbst meist deutlich kuerzer" \
            "${MIN_FREE_GB_ABSOLUTE} GB oder mehr" \
            "Wenn Home Assistant noch nicht eingerichtet wurde, nutze vorher ein passendes Setup mit lokaler oder hybrider Installation."
            begin_operation_measurement "main_menu_homeassistant" "Home Assistant starten"
            echo -e "${BLUE}Starte Home Assistant...${NC}"
            sudo systemctl start homeassistant@homeassistant
            if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            ;;
        17)
            print_exit_message
            exit 0
            ;;
        *)
            print_exit_message
            exit 0
            ;;
    esac
done
rm -f /tmp/menu_choice /tmp/profile_selection /tmp/tool_selection
