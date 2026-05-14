#!/bin/bash
#
# Skript: setup_ultimate.sh
# Beschreibung: Dies ist das Hauptinstallationsskript für die ultimative KI-Infrastruktur.
# Es bietet eine interaktive Menüführung zur Installation, Deinstallation und Verwaltung verschiedener KI-Tools, Profile und Systemkomponenten.
# Das Skript unterstützt hybride Setups (MiniPC + Multi-VPS), Standalone-Installationen und bietet Funktionen wie Auto-Updates, Ollama-Modellverwaltung und OpenClaw-Konfiguration.
# Version: V11.16
#

# Farben & UI
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"
APP_VERSION="11.16"
APP_TITLE="OpenClaw & AI Infrastructure - Ultimate Setup V${APP_VERSION}"

# Installationsverzeichnis
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
USER_STATUS_DIR="$USER_WORKSPACE_DIR/status"
USER_OPENCLAW_TEMPLATE_DIR="$USER_WORKSPACE_DIR/openclaw"
USER_PROFILE_SOURCE_DIR="$USER_WORKSPACE_DIR/profil_quellen"
USER_PROFILE_RENDERED_DIR="$USER_WORKSPACE_DIR/profile_ableitungen"
USER_PROMPTS_DIR="$USER_WORKSPACE_DIR/prompts"
USER_MODELFILE_DIR="$USER_WORKSPACE_DIR/modelfiles"
USER_METRICS_LOG_DIR="$USER_WORKSPACE_DIR/metrics_logs"
USER_INSTALL_LOG_DIR="$USER_WORKSPACE_DIR/install_logs"
USER_CUSTOM_SOURCE_DIR="$USER_WORKSPACE_DIR/custom_sources"
USER_DIALOGRC_FILE="$USER_WORKSPACE_DIR/dialogrc"
METRICS_CONFIG_FILE="$USER_WORKSPACE_DIR/setup_metrics.conf"
METRICS_HISTORY_FILE="$USER_METRICS_LOG_DIR/operation_history.tsv"
PROFILE_STATUS_FILE="$USER_WORKSPACE_DIR/installed_profiles.txt"
TOOL_STATUS_FILE="$USER_WORKSPACE_DIR/installed_tools.txt"
SETUP_PREFERENCES_FILE="$USER_WORKSPACE_DIR/setup_preferences.conf"
CUSTOM_SOURCES_FILE="$USER_WORKSPACE_DIR/custom_sources.conf"
CUSTOM_OLLAMA_BUILDS_FILE="$USER_WORKSPACE_DIR/custom_ollama_builds.conf"
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
    mkdir -p "$USER_STATUS_DIR"
    mkdir -p "$USER_OPENCLAW_TEMPLATE_DIR"
    mkdir -p "$USER_PROFILE_SOURCE_DIR"
    mkdir -p "$USER_PROFILE_RENDERED_DIR"
    mkdir -p "$USER_PROMPTS_DIR"
    mkdir -p "$USER_MODELFILE_DIR"
    mkdir -p "$USER_METRICS_LOG_DIR"
    mkdir -p "$USER_INSTALL_LOG_DIR"
    mkdir -p "$USER_CUSTOM_SOURCE_DIR"
    touch "$PROFILE_STATUS_FILE" "$TOOL_STATUS_FILE"

    if [ ! -s "$TOOL_STATUS_FILE" ] && [ -s "$USER_STATUS_DIR/installed_tools.txt" ]; then
        cp "$USER_STATUS_DIR/installed_tools.txt" "$TOOL_STATUS_FILE"
    elif [ ! -s "$USER_STATUS_DIR/installed_tools.txt" ] && [ -s "$TOOL_STATUS_FILE" ]; then
        cp "$TOOL_STATUS_FILE" "$USER_STATUS_DIR/installed_tools.txt"
    fi

    if [ ! -s "$PROFILE_STATUS_FILE" ] && [ -s "$USER_STATUS_DIR/installed_profiles.txt" ]; then
        cp "$USER_STATUS_DIR/installed_profiles.txt" "$PROFILE_STATUS_FILE"
    elif [ ! -s "$USER_STATUS_DIR/installed_profiles.txt" ] && [ -s "$PROFILE_STATUS_FILE" ]; then
        cp "$PROFILE_STATUS_FILE" "$USER_STATUS_DIR/installed_profiles.txt"
    fi

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

    if [ ! -f "$CUSTOM_SOURCES_FILE" ]; then
        cat > "$CUSTOM_SOURCES_FILE" <<'EOF'
# Benutzerdefinierte GitHub-Quellen für Setup, Tools und eigene Forks
# Format:
# CUSTOM_REPO_<SCHLUESSEL>_URL="https://github.com/owner/repo.git"
#
# Der Standard bleibt aktiv, wenn die Zeile leer bleibt oder auskommentiert ist.
# Die ursprüngliche Standardquelle ist jeweils im Kommentar dokumentiert.
#
# Hauptprogramme
# Standard OpenClaw: https://github.com/openclaw/openclaw.git
CUSTOM_REPO_OPENCLAW_URL=""
# Standard OpenManus: https://github.com/openmanus/openmanus.git
CUSTOM_REPO_OPENMANUS_URL=""
# Standard Open WebUI: https://github.com/open-webui/open-webui.git
CUSTOM_REPO_OPEN_WEBUI_URL=""
# Standard LiteLLM: https://github.com/BerriAI/litellm.git
CUSTOM_REPO_LITELLM_URL=""
# Standard ComfyUI: https://github.com/comfyanonymous/ComfyUI.git
CUSTOM_REPO_COMFYUI_URL=""
#
# Finanz- und Analyse-Repos
# Standard FinGPT: https://github.com/AI4Finance-Foundation/FinGPT.git
CUSTOM_REPO_FINGPT_URL=""
# Standard FinRobot: https://github.com/AI4Finance-Foundation/FinRobot.git
CUSTOM_REPO_FINROBOT_URL=""
# Standard FinRAG: https://github.com/AI4Finance-Foundation/FinRAG.git
CUSTOM_REPO_FINRAG_URL=""
EOF
    fi

    if [ ! -f "$CUSTOM_OLLAMA_BUILDS_FILE" ]; then
        cat > "$CUSTOM_OLLAMA_BUILDS_FILE" <<'EOF'
# Benutzerdefinierte Ollama-Builds und Fork-Notizen
# Für jeden eigenen Build kannst du hier einen gut lesbaren Block anlegen.
#
# Beispiel FinGPT-Fork:
# BUILD_FINGPT_FORK_NAME="fingpt-fork-local"
# BUILD_FINGPT_FORK_REPO_URL="https://github.com/DEINNAME/FinGPT.git"
# BUILD_FINGPT_FORK_REPO_REF="main"
# BUILD_FINGPT_FORK_SOURCE_DIR="$HOME/.openclaw_ultimate_user_data/custom_sources/fingpt-fork"
# BUILD_FINGPT_FORK_BASE_MODEL="qwen3:30b"
# BUILD_FINGPT_FORK_GGUF_PATH=""
# BUILD_FINGPT_FORK_MODEFILE_PATH="$HOME/.openclaw_ultimate_user_data/modelfiles/fingpt-fork-local.Modelfile"
# BUILD_FINGPT_FORK_NOTES="Nach Fine-Tuning/Export die GGUF-Datei eintragen und dann ollama create ausführen."
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

# Optionale, feinere Tool-Schätzwerte fuer Einzelinstallationen.
# Diese Werte greifen, wenn noch keine echte erfolgreiche Messung fuer das Tool vorliegt.
# Namensschema:
# <TOOLNAME>_TOOL_DURATION_ESTIMATE="..."
# <TOOLNAME>_TOOL_STORAGE_ESTIMATE="..."
#
# Haeufige Beispiele:
# OLLAMA_TOOL_DURATION_ESTIMATE
# OLLAMA_TOOL_STORAGE_ESTIMATE
# N8N_TOOL_DURATION_ESTIMATE
# N8N_TOOL_STORAGE_ESTIMATE
# OPENCLAW_TOOL_DURATION_ESTIMATE
# OPENCLAW_TOOL_STORAGE_ESTIMATE
# OPENMANUS_TOOL_DURATION_ESTIMATE
# OPENMANUS_TOOL_STORAGE_ESTIMATE
# COMFYUI_TOOL_DURATION_ESTIMATE
# COMFYUI_TOOL_STORAGE_ESTIMATE
# STABLE_DIFFUSION_WEBUI_FORGE_TOOL_DURATION_ESTIMATE
# STABLE_DIFFUSION_WEBUI_FORGE_TOOL_STORAGE_ESTIMATE
#
# Prioritaet im Setup:
# 1. letzte erfolgreiche echte Messung
# 2. dein hier eingetragener Wert
# 3. interner Fallback aus dem Setup
OLLAMA_TOOL_DURATION_ESTIMATE="5-15 min Installation, Modelle zusaetzlich je nach Groesse"
OLLAMA_TOOL_STORAGE_ESTIMATE="15-40 GB ohne Modelle, mit mehreren Modellen deutlich mehr"
N8N_TOOL_DURATION_ESTIMATE="10-30 min Klonen + Build bzw. Runtime-Installation"
N8N_TOOL_STORAGE_ESTIMATE="5-15 GB"
OPENCLAW_TOOL_DURATION_ESTIMATE="15-60 min Download + Build je nach System"
OPENCLAW_TOOL_STORAGE_ESTIMATE="15-40 GB je nach Build- und Statusdaten"
OPENMANUS_TOOL_DURATION_ESTIMATE="5-20 min Download + Einrichtung"
OPENMANUS_TOOL_STORAGE_ESTIMATE="5-15 GB"
COMFYUI_TOOL_DURATION_ESTIMATE="15-45 min plus Modell-Downloads"
COMFYUI_TOOL_STORAGE_ESTIMATE="30-120 GB je nach Modellen und Workflows"
STABLE_DIFFUSION_WEBUI_FORGE_TOOL_DURATION_ESTIMATE="20-60 min plus Modell-Downloads"
STABLE_DIFFUSION_WEBUI_FORGE_TOOL_STORAGE_ESTIMATE="40-150 GB je nach Modellen, LoRAs und Outputs"

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
DEVOPS_SRE_REQUIRED_GB="12-40"
DATA_ENGINEERING_REQUIRED_GB="20-60"
DOCUMENT_AI_REQUIRED_GB="15-40"
VOICE_ASSISTANT_REQUIRED_GB="10-25"
VIDEO_GENERATION_REQUIRED_GB="40-140"
IMAGE_GENERATION_REQUIRED_GB="25-90"
WEB3_CRYPTO_TOOLS_REQUIRED_GB="8-20"
COMPLIANCE_PRIVACY_REQUIRED_GB="6-15"
PERSONAL_KNOWLEDGE_OS_REQUIRED_GB="10-30"
REPO_MAINTAINER_REQUIRED_GB="6-15"

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

is_preference_enabled() {
    case "$(printf '%s' "${1:-false}" | tr '[:upper:]' '[:lower:]')" in
        1|true|yes|on|ja)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

set_installation_monitoring_mode() {
    local enabled="$1"

    enabled="$(normalize_setup_boolean "$enabled")"
    persist_setup_preference "INSTALL_MONITORING_VERBOSE" "$enabled"
    persist_setup_preference "INSTALL_MONITORING_MANUAL_FLOW" "$enabled"
    load_setup_language
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

format_kb_human() {
    local total_kb="${1:-0}"
    local abs_kb="$total_kb"

    if [ "${abs_kb#-}" != "$abs_kb" ]; then
        abs_kb="${abs_kb#-}"
    fi

    if [ "$abs_kb" -ge 1048576 ] 2>/dev/null; then
        awk -v kb="$total_kb" 'BEGIN {printf "%.1f GB", kb/1048576}'
    elif [ "$abs_kb" -ge 1024 ] 2>/dev/null; then
        awk -v kb="$total_kb" 'BEGIN {printf "%.1f MB", kb/1024}'
    else
        printf '%s KB' "$total_kb"
    fi
}

get_last_success_metric_field() {
    local operation_id="$1"
    local field_index="$2"

    ensure_user_workspace
    [ -f "$METRICS_HISTORY_FILE" ] || return 1

    awk -F'\t' -v opid="$operation_id" -v field="$field_index" '
        NR > 1 && $2 == opid && $4 == "success" {
            value = $field
        }
        END {
            if (value != "") {
                print value
            }
        }
    ' "$METRICS_HISTORY_FILE"
}

get_operation_duration_estimate_label() {
    local operation_id="$1"
    local fallback_label="$2"
    local duration_seconds

    duration_seconds="$(get_last_success_metric_field "$operation_id" 5)"
    if [ -n "$duration_seconds" ]; then
        printf '%s (letzte erfolgreiche Messung)' "$(format_duration_human "$duration_seconds")"
    else
        printf '%s' "$fallback_label"
    fi
}

get_operation_storage_estimate_label() {
    local operation_id="$1"
    local fallback_label="$2"
    local delta_kb

    delta_kb="$(get_last_success_metric_field "$operation_id" 8)"
    if [ -n "$delta_kb" ]; then
        printf '%s freier Speicher empfohlen, letzte erfolgreiche Aenderung: %s' "$fallback_label" "$(format_kb_human "$delta_kb")"
    else
        printf '%s' "$fallback_label"
    fi
}

get_default_tool_duration_label() {
    local tool_key="$1"

    case "$tool_key" in
        "Ollama") printf '5-15 min Installation, Modelle zusaetzlich je nach Groesse' ;;
        "n8n") printf '10-30 min Klonen + Build bzw. Runtime-Installation' ;;
        "OpenClaw") printf '15-60 min Download + Build je nach System' ;;
        "OpenManus") printf '5-20 min Download + Einrichtung' ;;
        "ComfyUI"|"Stable_Diffusion_WebUI_Forge") printf '15-45 min plus Modell-Downloads' ;;
        *) printf '%s Download + %s Installation/Anpassung je nach Tool' "${SETUP_DOWNLOAD_TIME_ESTIMATE}" "${SETUP_INSTALL_TIME_ESTIMATE}" ;;
    esac
}

tool_key_to_metric_prefix() {
    local tool_key="$1"

    printf '%s' "$tool_key" | tr '[:lower:]- /.' '[:upper:]____'
}

get_configured_tool_duration_label() {
    local tool_key="$1"
    local metric_prefix
    local metric_var_name

    metric_prefix="$(tool_key_to_metric_prefix "$tool_key")"
    metric_var_name="${metric_prefix}_TOOL_DURATION_ESTIMATE"
    printf '%s' "${!metric_var_name:-}"
}

get_configured_tool_storage_label() {
    local tool_key="$1"
    local metric_prefix
    local metric_var_name

    metric_prefix="$(tool_key_to_metric_prefix "$tool_key")"
    metric_var_name="${metric_prefix}_TOOL_STORAGE_ESTIMATE"
    printf '%s' "${!metric_var_name:-}"
}

get_default_tool_storage_label() {
    local tool_key="$1"

    case "$tool_key" in
        "Ollama") printf '15-40 GB ohne Modelle, mit mehreren Modellen deutlich mehr' ;;
        "n8n") printf '5-15 GB' ;;
        "ComfyUI"|"Stable_Diffusion_WebUI_Forge") printf '30-120 GB je nach Modellen und Workflows' ;;
        *) printf '%s-%s GB' "${MIN_FREE_GB_ABSOLUTE}" "${MIN_FREE_GB_RECOMMENDED}" ;;
    esac
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
    LAST_OPERATION_LOG_FILE="${ACTIVE_OPERATION_LOG_FILE:-}"

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
    if [ -n "${LAST_OPERATION_LOG_FILE:-}" ]; then
        echo -e "${YELLOW}Installationsprotokoll:${NC} ${LAST_OPERATION_LOG_FILE}"
    fi

    unset ACTIVE_OPERATION_ID ACTIVE_OPERATION_TITLE ACTIVE_OPERATION_STARTED_AT ACTIVE_OPERATION_FREE_KB_BEFORE ACTIVE_OPERATION_LOG_FILE
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
        "DevOps_SRE") echo "${DEVOPS_SRE_REQUIRED_GB} GB" ;;
        "Data_Engineering") echo "${DATA_ENGINEERING_REQUIRED_GB} GB" ;;
        "Document_AI") echo "${DOCUMENT_AI_REQUIRED_GB} GB" ;;
        "Voice_Assistant") echo "${VOICE_ASSISTANT_REQUIRED_GB} GB" ;;
        "Video_Generation") echo "${VIDEO_GENERATION_REQUIRED_GB} GB" ;;
        "Image_Generation") echo "${IMAGE_GENERATION_REQUIRED_GB} GB" ;;
        "Web3_Crypto_Tools") echo "${WEB3_CRYPTO_TOOLS_REQUIRED_GB} GB" ;;
        "Compliance_Privacy") echo "${COMPLIANCE_PRIVACY_REQUIRED_GB} GB" ;;
        "Personal_Knowledge_OS") echo "${PERSONAL_KNOWLEDGE_OS_REQUIRED_GB} GB" ;;
        "Repo_Maintainer") echo "${REPO_MAINTAINER_REQUIRED_GB} GB" ;;
        *) echo "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB" ;;
    esac
}

show_profile_action_intro() {
    local profile_key="$1"
    local action_label="$2"
    local operation_kind="${3:-install}"
    local required_gb
    local extra_notes
    local duration_label
    local operation_id="profile_${operation_kind}_${profile_key}"

    required_gb="$(get_profile_required_gb "$profile_key")"
    extra_notes="Je nach Profil werden mehrere Einzeltools nacheinander installiert oder entfernt. Das kann laenger dauern als bei einem Einzeltool."
    duration_label="$(get_operation_duration_estimate_label "$operation_id" "${SETUP_DOWNLOAD_TIME_ESTIMATE} Download + ${SETUP_INSTALL_TIME_ESTIMATE} Installation/Anpassung je nach Profilgroesse")"
    required_gb="$(get_operation_storage_estimate_label "$operation_id" "$required_gb")"

    case "$profile_key" in
        "Trading_AI"|"Web3_Crypto_Tools")
            extra_notes="${extra_notes} Achtung: Diese Profile sind standardmaessig fuer Analyse, Backtesting, Alerts und Paper-Trading gedacht. Keine autonome Live-Orderausfuehrung, keine Finanzberatung und keine Haftung fuer Verluste oder sonstige verursachte Schaeden."
            ;;
    esac

    show_operation_intro \
    "Profil ${action_label}: ${profile_key}" \
    "${PROFILES[$profile_key]}" \
    "$duration_label" \
    "$required_gb" \
    "$extra_notes"
}

show_tool_action_intro() {
    local tool_key="$1"
    local action_label="$2"
    local operation_kind="${3:-install}"
    local operation_id="tool_${operation_kind}_${tool_key}"
    local duration_label
    local storage_label
    local configured_duration
    local configured_storage

    configured_duration="$(get_configured_tool_duration_label "$tool_key")"
    configured_storage="$(get_configured_tool_storage_label "$tool_key")"

    duration_label="$(get_operation_duration_estimate_label "$operation_id" "${configured_duration:-$(get_default_tool_duration_label "$tool_key")}")"
    storage_label="$(get_operation_storage_estimate_label "$operation_id" "${configured_storage:-$(get_default_tool_storage_label "$tool_key")}")"

    show_operation_intro \
    "Tool ${action_label}: ${tool_key}" \
    "${TOOLS[$tool_key]}" \
    "$duration_label" \
    "$storage_label" \
    "Einige Tools benoetigen zusaetzliche Paketquellen, Builds, Container oder API-Eingaben."
}

run_bash_script() {
    local script_path="$1"
    shift || true
    local script_rc
    local operation_slug
    local timestamp_slug

    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Fehler: Skript nicht gefunden: $script_path${NC}"
        return 1
    fi

    ensure_user_workspace
    ACTIVE_OPERATION_LOG_FILE=""

    if is_preference_enabled "${INSTALL_MONITORING_VERBOSE:-false}"; then
        operation_slug="$(printf '%s' "${ACTIVE_OPERATION_ID:-$(basename "$script_path" .sh)}" | tr -cs '[:alnum:]_.-' '_')"
        timestamp_slug="$(date +%Y%m%d_%H%M%S)"
        ACTIVE_OPERATION_LOG_FILE="$USER_INSTALL_LOG_DIR/${timestamp_slug}_${operation_slug}.log"

        echo -e "${YELLOW}Erweiterte Installationsüberwachung ist aktiv.${NC}"
        echo -e "${YELLOW}Logdatei:${NC} ${ACTIVE_OPERATION_LOG_FILE}"
        bash "$script_path" "$@" 2>&1 | tee "$ACTIVE_OPERATION_LOG_FILE"
        script_rc=${PIPESTATUS[0]}
    else
        bash "$script_path" "$@"
        script_rc=$?
    fi

    reset_terminal_display
    return $script_rc
}

show_installation_monitoring_menu() {
    local monitoring_state

    while true; do
        if is_preference_enabled "${INSTALL_MONITORING_VERBOSE:-false}"; then
            monitoring_state="aktiv"
        else
            monitoring_state="inaktiv"
        fi

        dialog --clear --backtitle "$APP_TITLE" \
        --title "INSTALLATIONSÜBERWACHUNG" --menu "Zusätzliche Überwachung und manuelle Fortsetzung für Tool-Installationen." 20 104 5 \
        "1" "Erweiterte Installationsüberwachung umschalten (aktuell: ${monitoring_state})" \
        "2" "Log-Verzeichnis anzeigen" \
        "3" "Letzte Installations-Logs anzeigen" \
        "4" "Letzte Messwerte anzeigen" \
        "5" "Zurück" 2> /tmp/install_monitoring_choice

        if [ $? -ne 0 ]; then
            return 0
        fi

        case "$(cat /tmp/install_monitoring_choice)" in
            1)
                if is_preference_enabled "${INSTALL_MONITORING_VERBOSE:-false}"; then
                    set_installation_monitoring_mode "false"
                    echo -e "${GREEN}Erweiterte Installationsüberwachung wurde deaktiviert.${NC}"
                else
                    set_installation_monitoring_mode "true"
                    echo -e "${GREEN}Erweiterte Installationsüberwachung wurde aktiviert.${NC}"
                    echo -e "${YELLOW}Ab jetzt werden Tool-Installationen und -Deinstallationen zusätzlich ins Terminal protokolliert, in Logdateien geschrieben und nach jedem Schritt manuell bestätigt.${NC}"
                fi
                read -p "Drücken Sie Enter..."
                ;;
            2)
                clear
                echo
                echo -e "${YELLOW}Log-Verzeichnis für Installations- und Deinstallationsläufe:${NC}"
                echo "$USER_INSTALL_LOG_DIR"
                echo
                read -p "Drücken Sie Enter..."
                ;;
            3)
                show_recent_install_logs
                ;;
            4)
                show_recent_measurements
                ;;
            5)
                return 0
                ;;
        esac
    done
}

show_recent_install_logs() {
    local log_file
    local options=()
    local selected_log
    local full_path

    ensure_user_workspace
    mkdir -p "$USER_INSTALL_LOG_DIR"

    while IFS= read -r log_file; do
        [ -n "$log_file" ] || continue
        options+=("$log_file" "Installationsprotokoll")
    done < <(find "$USER_INSTALL_LOG_DIR" -maxdepth 1 -type f -name '*.log' -printf '%f\n' 2>/dev/null | sort -r | head -n 15)

    if [ ${#options[@]} -eq 0 ]; then
        clear
        echo
        echo -e "${YELLOW}Es wurden noch keine Installations- oder Deinstallationslogs gefunden.${NC}"
        echo -e "${YELLOW}Log-Verzeichnis:${NC} $USER_INSTALL_LOG_DIR"
        echo
        read -p "Drücken Sie Enter..."
        return 0
    fi

    dialog --clear --backtitle "$APP_TITLE" \
    --title "LETZTE INSTALLATIONS-LOGS" --menu "Wähle eine Logdatei zur Ansicht aus:" 22 110 15 \
    "${options[@]}" 2> /tmp/install_log_choice

    if [ $? -ne 0 ]; then
        return 0
    fi

    selected_log="$(cat /tmp/install_log_choice)"
    full_path="$USER_INSTALL_LOG_DIR/$selected_log"

    clear
    echo
    echo -e "${YELLOW}Installationslog:${NC} $full_path"
    echo
    tail -n 200 "$full_path"
    echo
    read -p "Drücken Sie Enter..."
}

handle_manual_tool_post_action() {
    local tool_key="$1"
    local action_label="$2"
    local current_log_file="${LAST_OPERATION_LOG_FILE:-}"
    local next_choice

    if ! is_preference_enabled "${INSTALL_MONITORING_MANUAL_FLOW:-false}"; then
        return 0
    fi

    echo
    echo -e "${YELLOW}Erweiterte Installationsüberwachung ist aktiv.${NC}"
    echo -e "${YELLOW}Nach dem Schritt '${action_label} ${tool_key}' wird nicht automatisch weitergesprungen.${NC}"
    if [ -n "$current_log_file" ]; then
        echo -e "${YELLOW}Logdatei:${NC} $current_log_file"
    fi

    while true; do
        read -r -p "Weiter mit der nächsten Installation/Deinstallation [N] oder zurück ins Setup [Z]? " next_choice
        case "$(printf '%s' "${next_choice:-N}" | tr '[:lower:]' '[:upper:]')" in
            N|"")
                TOOL_BATCH_ABORT_REQUESTED=0
                break
                ;;
            Z)
                TOOL_BATCH_ABORT_REQUESTED=1
                break
                ;;
            *)
                echo -e "${YELLOW}Bitte nur N oder Z eingeben.${NC}"
                ;;
        esac
    done

    LAST_OPERATION_LOG_FILE=""
}

handle_manual_profile_post_action() {
    local profile_key="$1"
    local action_label="$2"
    local current_log_file="${LAST_OPERATION_LOG_FILE:-}"
    local next_choice

    if ! is_preference_enabled "${INSTALL_MONITORING_MANUAL_FLOW:-false}"; then
        return 0
    fi

    echo
    echo -e "${YELLOW}Erweiterte Installationsüberwachung ist aktiv.${NC}"
    echo -e "${YELLOW}Nach dem Schritt '${action_label} ${profile_key}' wird nicht automatisch weitergesprungen.${NC}"
    if [ -n "$current_log_file" ]; then
        echo -e "${YELLOW}Logdatei:${NC} $current_log_file"
    fi

    while true; do
        read -r -p "Zurück ins Profilmenü [N] oder direkt zurück ins Setup [Z]? " next_choice
        case "$(printf '%s' "${next_choice:-N}" | tr '[:lower:]' '[:upper:]')" in
            N|"")
                PROFILE_FLOW_ABORT_REQUESTED=0
                break
                ;;
            Z)
                PROFILE_FLOW_ABORT_REQUESTED=1
                break
                ;;
            *)
                echo -e "${YELLOW}Bitte nur N oder Z eingeben.${NC}"
                ;;
        esac
    done

    LAST_OPERATION_LOG_FILE=""
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
        --cancel-label "↩ Zurück" \
        --title "${TXT_OPTIONS_MENU_TITLE:-OPTIONEN}" --menu "${TXT_OPTIONS_MENU_PROMPT:-Wählen Sie eine Verwaltungs- oder Konfigurationsfunktion:}" 30 100 15 \
        "1" "${TXT_OPTIONS_1:-Sprache ändern}" \
        "2" "${TXT_OPTIONS_2:-Setup-Messwerte & Benchmarks bearbeiten}" \
        "3" "${TXT_OPTIONS_3:-Ollama Modelfile-Assistent}" \
        "4" "${TXT_OPTIONS_4:-LLM-Builder Projektstruktur-Assistent}" \
        "5" "${TXT_OPTIONS_5:-Ollama Modellkatalog}" \
        "6" "${TXT_OPTIONS_6:-Setup-Repository hart reparieren / auf GitHub main zurücksetzen}" \
        "7" "${TXT_OPTIONS_7:-Benutzer-Workspace verwalten}" \
        "8" "${TXT_OPTIONS_8:-Custom GitHub-Quellen & Ollama-Builds}" \
        "9" "${TXT_OPTIONS_9:-LLMOps Plattform Konfiguration (.env Stack)}" \
        "10" "${TXT_OPTIONS_10:-Huginn Konfiguration (.env Vorlage)}" \
        "11" "${TXT_OPTIONS_11:-Installationsüberwachung konfigurieren}" \
        "12" "${TXT_OPTIONS_12:-Nur auf Setup-Updates prüfen}" \
        "13" "${TXT_OPTIONS_13:-Jetzt nur das Setup aktualisieren}" \
        "14" "${TXT_OPTIONS_14:-Sprachpakete verwalten}" \
        "15" "${TXT_OPTIONS_15:-Tool-Logdiagnose anzeigen / optional per E-Mail senden}" 2> /tmp/options_choice

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
                run_bash_script "$INSTALL_DIR/scripts/llm_builder_project_scaffold.sh"
                ;;
            5)
                run_bash_script "$INSTALL_DIR/scripts/ollama_model_catalog_manager.sh"
                ;;
            6)
                show_operation_intro \
                "Harter Setup-Abgleich mit GitHub main" \
                "Das Setup-Repository wird zwangsweise auf origin/main zurückgesetzt. Lokale Änderungen im Setup-Verzeichnis gehen dabei verloren." \
                "Meist nur wenige Minuten, abhängig von Netzwerk und Repo-Größe" \
                "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB" \
                "Nutze diese Methode nur, wenn das normale Update nicht greift oder ein alter Setup-Stand festhaengt."
                run_bash_script "$INSTALL_DIR/scripts/auto_update_hard.sh"
                read -p "Harter Setup-Abgleich abgeschlossen. Drücken Sie Enter..."
                ;;
            7)
                show_user_workspace_menu
                ;;
            8)
                run_bash_script "$INSTALL_DIR/scripts/custom_source_manager.sh"
                ;;
            9)
                run_bash_script "$INSTALL_DIR/scripts/llmops_platform_config_manager.sh"
                ;;
            10)
                run_bash_script "$INSTALL_DIR/scripts/huginn_config_manager.sh"
                ;;
            11)
                show_installation_monitoring_menu
                ;;
            12)
                show_operation_intro \
                "Nur auf Setup-Updates prüfen" \
                "Prüft den lokalen Git-Stand gegen origin/main, ohne direkt Updates oder Systempakete zu installieren." \
                "Wenige Sekunden bis ca. 1 Minute, je nach Netzwerk und Git-Status" \
                "$(get_operation_storage_estimate_label "main_menu_update_check" "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB")" \
                "Dabei werden keine Paket-Updates installiert und keine lokalen Aenderungen automatisch verworfen."
                begin_operation_measurement "main_menu_update_check" "Nur auf Setup-Updates prüfen"
                run_bash_script "$INSTALL_DIR/scripts/check_setup_updates.sh"
                if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
                read -p "Update-Prüfung abgeschlossen. Drücken Sie Enter..."
                ;;
            13)
                show_operation_intro \
                "Jetzt nur das Setup aktualisieren" \
                "Aktualisiert nur dieses Setup-Repository gegen origin/main. Betriebssystem und pnpm bleiben dabei unberuehrt." \
                "Wenige Sekunden bis einige Minuten, je nach Netzwerk und Git-Stand" \
                "$(get_operation_storage_estimate_label "main_menu_setup_only_update" "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB")" \
                "Bei lokalen Aenderungen im Setup wird das Repo-Update bewusst uebersprungen, damit nichts ueberschrieben wird."
                begin_operation_measurement "main_menu_setup_only_update" "Nur das Setup aktualisieren"
                run_bash_script "$INSTALL_DIR/scripts/update_setup_only.sh"
                if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
                read -p "Setup-Update abgeschlossen. Drücken Sie Enter..."
                ;;
            14)
                run_bash_script "$INSTALL_DIR/scripts/language_pack_manager.sh"
                ;;
            15)
                bash "$INSTALL_DIR/scripts/tool_log_diagnostics.sh"
                read -p "Tool-Logdiagnose abgeschlossen. Drücken Sie Enter..."
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

    if [ -d /opt/huginn ]; then
        if ! grep -Fxq "Huginn" "$TOOL_STATUS_FILE" 2>/dev/null; then
            append_unique_line "$TOOL_STATUS_FILE" "Huginn"
            status_changed=1
        fi
    fi

    if [ -d /opt/clawhub-cli ]; then
        if ! grep -Fxq "Clawhub_CLI" "$TOOL_STATUS_FILE" 2>/dev/null; then
            append_unique_line "$TOOL_STATUS_FILE" "Clawhub_CLI"
            status_changed=1
        fi
    fi

    if [ "$status_changed" -eq 1 ]; then
        echo -e "${BLUE}Hinweis: Der Tool-Status fuer vorhandene Kern- und Zusatzinstallationen wurde aus dem System nachsynchronisiert.${NC}"
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
PROFILE_KEYS=("Programmierer" "Repo_Maintainer" "Agent_Orchestrator" "LLM_Builder" "Research_Agent" "KI_Forschung" "Data_Engineering" "Document_AI" "Personal_Knowledge_OS" "Next_Level_Persona_System" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht" "DevOps_SRE" "Security_Analyst" "Ethical_HackerGPT" "Compliance_Privacy" "Audio" "Voice_Assistant" "Media_Musik" "Content_Automation" "Image_Generation" "Video_Generation" "Visual_Creator" "Trading_AI" "Web3_Crypto_Tools")
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
PROFILES["Ethical_HackerGPT"]="Defensiver Security-Assistent fuer autorisierte Audits, Hardening, Reporting und lokale Lab-Umgebungen mit strikter Allowlist und Audit-Default."
PROFILES["Trading_AI"]="Unterstuetzt Marktanalyse, Strategietests, Backtesting und Paper-Trading mit Zenbot sowie Web3- und Exchange-Integrationen. Keine autonome Live-Orderausfuehrung."
PROFILES["Visual_Creator"]="Kreativprofil für Bild-, Video- und Asset-Pipelines mit Diffusions-, UI- und Upscaling-Bausteinen."
PROFILES["LLM_Builder"]="Baut einen realistischen lokalen Workflow zum Fine-Tuning, Testen, Exportieren und Quantisieren eigener Modelle für Ollama auf."
PROFILES["DevOps_SRE"]="Betriebsprofil für Deployment, Logs, Monitoring, Rollback, GitOps und Infrastruktur-Wartung auf lokalem Host, VPS oder K3s."
PROFILES["Data_Engineering"]="Datenprofil für ETL, Dokumentenaufbereitung, RAG-Vorbereitung, lokale Datenpipelines und BI-nahe Vorarbeit."
PROFILES["Document_AI"]="Dokumentenprofil für OCR, PDF, Formulare, Verträge, Rechnungen und lokale Wissensablage mit Parser- und DMS-Bausteinen."
PROFILES["Voice_Assistant"]="Sprachprofil für STT, TTS, Wakeword, Rhasspy/Wyoming und Smart-Home-nahe Sprachassistenten."
PROFILES["Video_Generation"]="Heavy-Profil für lokale Video-KI, Upscaling, Frame-Interpolation, FFmpeg und GPU-nahe Video-Workflows."
PROFILES["Image_Generation"]="Heavy-Profil für Bildgenerierung, Upscaling, LoRA-Workflows und Asset-Erzeugung mit ComfyUI/Forge/Fooocus."
PROFILES["Web3_Crypto_Tools"]="Web3-Werkzeuge fuer lokale Vertragsanalyse, RPC-Checks und Wallet-nahe Entwicklung ohne automatische Finanzaktionen oder autonome Trading-Ausfuehrung."
PROFILES["Compliance_Privacy"]="Governance- und Compliance-Profil für DSGVO, EU-AI-Act-nahe Prüfungen, Policies, SBOM und Secret-Scans."
PROFILES["Personal_Knowledge_OS"]="Persönliches Wissensprofil für lokale Suche, RAG, Sync, Export und Memory-Workflows."
PROFILES["Next_Level_Persona_System"]="Modulares Persona-System fuer persistente Charaktere, Moduswechsel, Memory, Disclosure-Regeln und spaetere Voice-/Multimodal-Hooks."
PROFILES["Repo_Maintainer"]="Maintainer-Profil für GitHub-Repo-Pflege, lokale CI, Linting, Releases, Changelogs und Pre-Commit-Prüfungen."

# Funktion zum Installieren eines Profils
install_profile() {
    local PROFILE_KEY="$1"
    show_profile_action_intro "$PROFILE_KEY" "installieren" "install"
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
    handle_manual_profile_post_action "$PROFILE_KEY" "Profil-Installation"
}

# Funktion zum Deinstallieren eines Profils
uninstall_profile() {
    local PROFILE_KEY="$1"
    show_profile_action_intro "$PROFILE_KEY" "deinstallieren" "uninstall"
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
    handle_manual_profile_post_action "$PROFILE_KEY" "Profil-Deinstallation"
}

# Funktion zum Anzeigen des Profil-Management-Menüs
show_profile_management_menu() {
    PROFILE_FLOW_ABORT_REQUESTED=0
    ensure_user_workspace
    normalize_status_file "$PROFILE_STATUS_FILE" "${PROFILE_KEYS[@]}"

    if ! is_base_install_ready; then
        echo -e "${YELLOW}Hinweis: Ollama und/oder OpenClaw sind aktuell noch nicht vollständig installiert.${NC}"
        echo -e "${YELLOW}Die Profilverwaltung kann trotzdem geöffnet werden. Einige Profile benötigen für die volle Funktion aber die Basis-Installation.${NC}"
    fi

    declare -A INSTALLED_PROFILES_MAP
    load_installed_map "$PROFILE_STATUS_FILE" INSTALLED_PROFILES_MAP

    PROFILE_MENU_OPTIONS=()
    for profile_key in "${PROFILE_KEYS[@]}"; do
        local profile_status_text="Nicht installiert"
        if [ -n "$profile_key" ] && [ "${INSTALLED_PROFILES_MAP[$profile_key]:-}" = "1" ]; then
            profile_status_text="Installiert"
        fi
        PROFILE_MENU_OPTIONS+=("$profile_key" "[$profile_status_text] ${PROFILES[$profile_key]}")
    done

    while true; do
        dialog --clear --backtitle "$APP_TITLE" \
        --title "PROFIL-MANAGEMENT" --menu "Wählen Sie ein Profil für die Detailansicht. Dort können Sie das Gesamtprofil oder einzelne enthaltene Tools installieren bzw. deinstallieren:" 28 108 18 \
        "${PROFILE_MENU_OPTIONS[@]}" \
        "ZURUECK" "Zurück zum Profil-Hub" 2> /tmp/profile_selection

        if [ $? -ne 0 ]; then
            return 0
        fi

        local selected_profile
        selected_profile="$(cat /tmp/profile_selection)"

        if [ "$selected_profile" = "ZURUECK" ]; then
            return 0
        fi

        show_profile_block_detail_menu "$selected_profile"
        if [ "${PROFILE_FLOW_ABORT_REQUESTED:-0}" = "1" ]; then
            return 0
        fi
        load_installed_map "$PROFILE_STATUS_FILE" INSTALLED_PROFILES_MAP
        PROFILE_MENU_OPTIONS=()
        for profile_key in "${PROFILE_KEYS[@]}"; do
            local refreshed_status_text="Nicht installiert"
            if [ -n "$profile_key" ] && [ "${INSTALLED_PROFILES_MAP[$profile_key]:-}" = "1" ]; then
                refreshed_status_text="Installiert"
            fi
            PROFILE_MENU_OPTIONS+=("$profile_key" "[$refreshed_status_text] ${PROFILES[$profile_key]}")
        done
    done
}

# --- Funktionen für Tool-Management ---

declare -A TOOLS
declare -A TOOL_SCRIPT_NAMES
TOOL_KEYS=("Ollama" "OpenClaw" "Act" "Actionlint" "Activepieces" "Agent_Router" "Ahrefs" "AI_Powered_Law_Firms" "Aider" "Airbyte" "Airtable" "AnimateDiff" "Ansible" "Apache_Tika" "ArgoCD_CLI" "AutoGen" "AutoGPT" "Axolotl" "Backtest_Workflow" "Blender" "BPM_Analyzer" "Browser_Tool" "Buffer_API" "cAdvisor" "Changelog_Generator" "ChromaDB" "Clawbake" "Clawhub" "Clawhub_CLI" "Code_Sandbox" "ComfyUI" "Continue_Dev" "ControlNet" "Coqui_TTS" "CrewAI" "Data_Juicer" "dbt" "Deadline_Checker" "Demucs" "Docker" "Docker_Compose_Plugin" "Docling" "Drafting_Agent" "DuckDB" "ElevenLabs" "Emotion_Tagging" "EnviroLLM" "Ethers_JS" "EULLM" "Exchange_APIs" "Fail2Ban" "Fail2Ban_Analyzer" "Faster_Whisper" "FFmpeg" "File_System_Tool" "FinGPT" "FinRAG" "FinRobot" "Firecrawl" "Flowise" "Flux_CLI" "Fooocus" "Foundry" "GFPGAN" "GitHub_API_Tooling" "GitHub_CLI" "GitHub_Research" "Gitleaks" "Google_Analytics_API" "Grafana" "Grafana_Alloy" "Grype" "Guardrails_AI" "Hadolint" "Hardhat" "Healthchecks" "Helm" "Home_Assistant" "Hook_Detection" "HubSpot" "Huge_Facing" "Huginn" "Image_Upscaler_Pipeline" "InvokeAI" "Joplin_CLI" "JupyterLab" "K3s" "K9s" "Kimi2" "Kubectl" "Kubectx_Kubens" "Kubernetes" "Kustomize" "LangChain" "LangFlow" "Langfuse" "LangGraph" "Lawfirm" "LibreOffice_Headless" "librosa" "LiteLLM" "Llama_CPP" "Llama_CPP_Toolchain" "LLaMA_Factory" "LlamaIndex" "Loki" "Make" "Markdownlint_CLI" "Marker" "MCPO" "Meilisearch" "Memory_Policies" "Meta_Ads_API" "Metabase" "MinIO" "MLflow" "Mosquitto" "Music2P_Pipeline" "MusicGen" "n8n" "NATS" "Neo4j" "Netdata" "Nikto" "Nmap" "Node_Exporter" "Node_Red" "Notion" "OCRmyPDF" "OPA" "Open_WebUI" "OpenClaw_RL" "OpenCode" "OpenHands" "OpenLIT" "OpenManus" "OpenTelemetry" "OpenTofu" "openWakeWord" "Pandoc" "Paperless_NGX" "PDF_Parser" "Pgvector" "Pipedream" "Piper" "Playwright" "Podman" "Postgres" "Pre_Commit" "Prefect" "Prometheus" "Promptfoo" "Puppeteer" "pydub" "Qdrant" "RabbitMQ" "Ray" "Rclone" "RealESRGAN" "Redis" "Release_Please" "Rembg" "Repo_Comparison" "Restic" "Rhasspy" "RIFE" "Riffusion" "Risk_Agent" "Risk_Scoring" "Risk_Strategy_Analyzer" "Runway_API" "Security_Workflow" "Semgrep" "SEMrush" "ShellCheck" "Shfmt" "SQLite" "SQLite_Vec" "Stable_Diffusion_WebUI" "Stable_Diffusion_WebUI_Forge" "Stirling_PDF" "Suno_API" "Supabase" "SVD" "Syft" "Syncthing" "Tax_Calculator" "Tax_Law_Agent" "Tesseract" "Thumbnail_Pipeline" "TikTok_Ads_API" "TikTok_Score" "Trend_Monitor" "Trivy" "TruffleHog" "Udio_API" "Unsloth" "Unstructured" "Upload_Automation" "Uptime_Kuma" "Vault" "Velero" "vLLM" "Voice_Assistant_Runtime" "VS_Code_Server" "Weaviate" "Web3_APIs" "Web3_Py" "Weights_and_Biases" "Whisper" "Whisper_CPP" "Wyoming" "YT_DLP" "Zapier" "Zenbot_API" "Zenbot_trader" "Zotero")
TOOLS["Ollama"]="Lokales LLM-Backend. Du kannst über den Ollama Modell-Manager spezifische Modelle installieren und verwalten. Für weitere Informationen zu den Modellen siehe in der Online-Dokumentation nach."
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
TOOLS["FinGPT"]="GitHub-basierter Open-Source-Finanz-LLM-Stack für Analyse, Fine-Tuning und Finanzaufgaben."
TOOLS["FinRobot"]="Agentische Open-Source-Plattform für Finanzanalyse, Reports und Research-Workflows."
TOOLS["FinRAG"]="Finanz-RAG-Stack für Berichte, Dokumente und lokale Wissensabfragen."
TOOLS["Nmap"]="Port- und Netzwerkscanner für Security-Checks und Exposure-Analysen."
TOOLS["Nikto"]="Webserver-Scanner für grundlegende Sicherheits- und Exposure-Prüfungen."
TOOLS["Trivy"]="Scanner für Container, Images und Abhängigkeiten mit Fokus auf Sicherheitslücken."
TOOLS["Fail2Ban"]="Schutz- und Log-Baustein gegen auffällige Login-Muster und Brute-Force-Versuche."
TOOLS["Stable_Diffusion_WebUI"]="WebUI-basierte Bildgenerierung und Prompt-Arbeit für visuelle Pipelines."
TOOLS["Stable_Diffusion_WebUI_Forge"]="Forge-Variante der Stable-Diffusion-WebUI für moderne GPU- und Modell-Workflows."
TOOLS["ComfyUI"]="Node-basierte visuelle Pipeline für Bild- und Video-Workflows."
TOOLS["RealESRGAN"]="Upscaling-Tool für Bilder, Thumbnails und visuelle Assets."
TOOLS["GFPGAN"]="Gesichtsrestauration für Portraits und nachgelagerte Bildpipelines."
TOOLS["Rembg"]="Hintergrundentfernung für Bildassets, Produktbilder und Freisteller-Workflows."
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
TOOLS["LiteLLM"]="Zentrales Model-Gateway für Ollama, Gemini und OpenAI mit Routing, Logging und Fallbacks."
TOOLS["Open_WebUI"]="Standard-Frontend für Chats, Multi-Model-Nutzung, RAG und Agenten-Workflows."
TOOLS["Langfuse"]="LLM-Observability-Plattform für Traces, Prompts, Kosten und Produktionsanalyse."
TOOLS["OpenLIT"]="OpenTelemetry-native Instrumentierung für LLM-, Agenten- und RAG-Workflows."
TOOLS["MCPO"]="MCP-zu-OpenAPI-Proxy für sichere HTTP-basierte Toolserver und Open-WebUI-Integration."
TOOLS["Continue_Dev"]="Open-Source Coding-Assistant-Workspace für IDE-nahe LLM-Entwicklung."
TOOLS["Guardrails_AI"]="Framework für Sicherheitsregeln, Validierung und Prompt-/Output-Schutz."
TOOLS["Promptfoo"]="Test- und Red-Teaming-Framework für Prompts, Agenten und RAG."
TOOLS["Gitleaks"]="Secrets-Scanner für Repositories, Commits und Dateien."
TOOLS["Uptime_Kuma"]="Self-Hosted Uptime- und URL-Monitoring für Dienste und Agentenendpunkte."
TOOLS["Netdata"]="System- und Container-Monitoring mit Live-Metriken."
TOOLS["MinIO"]="S3-kompatibler Objekt-Storage für Artefakte, Exporte und Plattformdaten."
TOOLS["Supabase"]="Self-Hosted Backend-Plattform mit Postgres, Auth, Storage und Realtime."
TOOLS["Healthchecks"]="Heartbeat- und Cronjob-Monitoring für Skripte, Backups und periodische Prozesse."
TOOLS["Ansible"]="Automatisiert Konfiguration, Rollouts und Host-Wartung über deklarative Playbooks."
TOOLS["OpenTofu"]="Open-Source-Infrastruktur als Code für reproduzierbare Cloud- und Host-Ressourcen."
TOOLS["K9s"]="Terminal-UI für Kubernetes/K3s-Clusterbetrieb und schnelle Statusdiagnose."
TOOLS["Helm"]="Paketmanager für Kubernetes- und K3s-Deployments."
TOOLS["Kubectl"]="Zentrale CLI für Kubernetes- und K3s-Ressourcen."
TOOLS["Kustomize"]="Deklaratives Overlay-Tool für Kubernetes-Manifeste."
TOOLS["Act"]="Lokale Ausführung von GitHub-Actions-Workflows zur schnellen CI-Prüfung."
TOOLS["Pre_Commit"]="Lokale Git-Hooks für Lints, Formatierung und Sicherheitsprüfungen vor Commits."
TOOLS["Markdownlint_CLI"]="CLI-Linter für Markdown-Struktur und Dokuqualität."
TOOLS["ShellCheck"]="Shell-Skript-Linter für Bash-Qualität und Fehlerprävention."
TOOLS["Shfmt"]="Formatter für Shell-Skripte."
TOOLS["Hadolint"]="Linter für Dockerfiles und Container-Builds."
TOOLS["Actionlint"]="Linter für GitHub-Actions-Workflows."
TOOLS["Docker_Compose_Plugin"]="Stellt das Docker-Compose-Plugin für moderne Compose-Stacks bereit."
TOOLS["TruffleHog"]="Secret-Scanner für Dateisysteme und Repositories."
TOOLS["ArgoCD_CLI"]="GitOps-CLI für Argo CD."
TOOLS["Flux_CLI"]="GitOps-CLI für Flux-basierte Cluster-Workflows."
TOOLS["Kubectx_Kubens"]="Schneller Wechsel zwischen Kubernetes-Kontexten und Namespaces."
TOOLS["Velero"]="Backup- und Restore-Werkzeug für Kubernetes-Ressourcen und Volumes."
TOOLS["Grafana_Alloy"]="Lightweight-Agent für Logs, Metrics und Telemetrie im Grafana-Stack."
TOOLS["cAdvisor"]="Container-Monitoring für Ressourcen, Volumes und Prozessnutzung."
TOOLS["Node_Exporter"]="Host-Metriken für Prometheus."
TOOLS["DuckDB"]="Analytische eingebettete Datenbank für lokale ETL- und BI-Workflows."
TOOLS["JupyterLab"]="Notebook- und Analyseumgebung für Daten, ML und Reports."
TOOLS["Airbyte"]="Connector-basierte Dateningestion für ETL und Analytics."
TOOLS["Metabase"]="BI-Oberfläche für Dashboards und Abfragen."
TOOLS["dbt"]="Transformation, Modellierung und Tests für analytische Daten."
TOOLS["Apache_Tika"]="Dokumentenparser für Text-, PDF- und Office-Inhalte."
TOOLS["Docling"]="Dokument-zu-strukturiert-Content Pipeline für lokale Verarbeitungsworkflows."
TOOLS["Pandoc"]="Konverter für Markdown, HTML, DOCX und weitere Dokumentformate."
TOOLS["OCRmyPDF"]="OCR-Pipeline für gescannte PDFs."
TOOLS["Paperless_NGX"]="Dokumentenmanagement mit OCR, Tags und Suche."
TOOLS["Stirling_PDF"]="Self-Hosted PDF-Werkzeugkasten für Konvertierung, Merge und Struktur."
TOOLS["Whisper_CPP"]="Lokale Speech-to-Text Engine auf Basis von Whisper.cpp."
TOOLS["Faster_Whisper"]="Beschleunigte Whisper-Variante für lokale STT-Workflows."
TOOLS["openWakeWord"]="Wakeword-Erkennung für lokale Sprachassistenten."
TOOLS["Rhasspy"]="Lokaler Sprachassistent mit Home- und Voice-Fokus."
TOOLS["Wyoming"]="Python-/Service-Baustein für Wyoming-Protokoll und Sprachkomponenten."
TOOLS["Tesseract"]="OCR-Engine für Dokumente und Scan-Verarbeitung."
TOOLS["Marker"]="PDF-/Dokumentenverarbeitung mit Marker-PDF."
TOOLS["LibreOffice_Headless"]="Headless-Office-Konvertierung für Dokumentenpipelines."
TOOLS["RIFE"]="Frame-Interpolation für Video- und Render-Workflows."
TOOLS["Fooocus"]="Einsteigerfreundlicher Bildgenerator auf Stable-Diffusion-Basis."
TOOLS["InvokeAI"]="Lokale Bildgenerierungsplattform mit Modell- und Workflowverwaltung."
TOOLS["Blender"]="3D-, Render- und Asset-Werkzeug für Game-, Video- und Kreativprofile."
TOOLS["Foundry"]="Toolchain für EVM-Smart-Contracts, Tests und RPC-Workflows."
TOOLS["Hardhat"]="JavaScript/TypeScript-Toolchain für Smart-Contract-Entwicklung."
TOOLS["Ethers_JS"]="JavaScript-Bibliothek für RPC-, Wallet- und Contract-Zugriffe."
TOOLS["Web3_Py"]="Python-Bibliothek für lokale Web3-Workflows."
TOOLS["OPA"]="Open Policy Agent für Policies, Compliance und Governance."
TOOLS["Meilisearch"]="Leichte Suchmaschine für persönliche Wissens- und DMS-Workflows."
TOOLS["Joplin_CLI"]="CLI-basierter Notiz- und Wissensspeicher."
TOOLS["Syncthing"]="Peer-to-Peer-Synchronisierung für lokale Daten und Notizen."
TOOLS["SQLite_Vec"]="Leichter lokaler Vektor-Speicher auf SQLite-Basis."
TOOLS["Release_Please"]="Release-Automatisierung für semantische Versionen und PR-gesteuerte Releases."
TOOLS["Changelog_Generator"]="CLI zur Erzeugung strukturierter Changelogs aus Commits."
TOOLS["Pgvector"]="Postgres-Erweiterung für Embeddings und Vektorsuche."
TOOLS["Prefect"]="Python-orchestrierte Daten- und ETL-Workflows."
TOOLS["Unstructured"]="Dokumenten- und Inhaltszerlegung für ETL, RAG und Parsing."
TOOLS["Home_Assistant"]="Smart-Home-Zentrale für lokale Automatisierung."
TOOLS["Restic"]="Backup-Werkzeug für versionierte Sicherungen auf lokale und entfernte Ziele."
TOOLS["Rclone"]="Synchronisations- und Cloud-Transfer-Werkzeug für Backups und Datenmigration."
TOOLS["Syft"]="SBOM-Scanner zur Erzeugung von Paket- und Container-Stücklisten."
TOOLS["Grype"]="Vulnerability-Scanner für Container, Pakete und SBOMs."
TOOLS["Semgrep"]="Statischer Code-Scanner für Security-Regeln und Richtlinienprüfungen."
TOOLS["Mosquitto"]="Leichtgewichtiger MQTT-Broker für Smart Home, Voice und lokale Eventbus-Setups."
TOOLS["Node_Red"]="Low-Code-Flow-Engine für Automation und Smart Home."
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
TOOL_SCRIPT_NAMES["FinGPT"]="fingpt"
TOOL_SCRIPT_NAMES["FinRobot"]="finrobot"
TOOL_SCRIPT_NAMES["FinRAG"]="finrag"
TOOL_SCRIPT_NAMES["Nmap"]="nmap"
TOOL_SCRIPT_NAMES["Nikto"]="nikto"
TOOL_SCRIPT_NAMES["Trivy"]="trivy"
TOOL_SCRIPT_NAMES["Fail2Ban"]="fail2ban"
TOOL_SCRIPT_NAMES["Stable_Diffusion_WebUI"]="stable_diffusion_webui"
TOOL_SCRIPT_NAMES["Stable_Diffusion_WebUI_Forge"]="stable_diffusion_webui_forge"
TOOL_SCRIPT_NAMES["ComfyUI"]="comfyui"
TOOL_SCRIPT_NAMES["RealESRGAN"]="realesrgan"
TOOL_SCRIPT_NAMES["GFPGAN"]="gfpgan"
TOOL_SCRIPT_NAMES["Rembg"]="rembg"
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
TOOL_SCRIPT_NAMES["LiteLLM"]="litellm"
TOOL_SCRIPT_NAMES["Open_WebUI"]="open_webui"
TOOL_SCRIPT_NAMES["Langfuse"]="langfuse"
TOOL_SCRIPT_NAMES["OpenLIT"]="openlit"
TOOL_SCRIPT_NAMES["MCPO"]="mcpo"
TOOL_SCRIPT_NAMES["Continue_Dev"]="continue_dev"
TOOL_SCRIPT_NAMES["Guardrails_AI"]="guardrails_ai"
TOOL_SCRIPT_NAMES["Promptfoo"]="promptfoo"
TOOL_SCRIPT_NAMES["Gitleaks"]="gitleaks"
TOOL_SCRIPT_NAMES["Uptime_Kuma"]="uptime_kuma"
TOOL_SCRIPT_NAMES["Netdata"]="netdata"
TOOL_SCRIPT_NAMES["MinIO"]="minio"
TOOL_SCRIPT_NAMES["Supabase"]="supabase"
TOOL_SCRIPT_NAMES["Healthchecks"]="healthchecks"
TOOL_SCRIPT_NAMES["Ansible"]="ansible"
TOOL_SCRIPT_NAMES["OpenTofu"]="opentofu"
TOOL_SCRIPT_NAMES["K9s"]="k9s"
TOOL_SCRIPT_NAMES["Helm"]="helm"
TOOL_SCRIPT_NAMES["Kubectl"]="kubectl"
TOOL_SCRIPT_NAMES["Kustomize"]="kustomize"
TOOL_SCRIPT_NAMES["Act"]="act"
TOOL_SCRIPT_NAMES["Pre_Commit"]="pre_commit"
TOOL_SCRIPT_NAMES["Markdownlint_CLI"]="markdownlint_cli"
TOOL_SCRIPT_NAMES["ShellCheck"]="shellcheck_cli"
TOOL_SCRIPT_NAMES["Shfmt"]="shfmt"
TOOL_SCRIPT_NAMES["Hadolint"]="hadolint"
TOOL_SCRIPT_NAMES["Actionlint"]="actionlint"
TOOL_SCRIPT_NAMES["Docker_Compose_Plugin"]="docker_compose_plugin"
TOOL_SCRIPT_NAMES["TruffleHog"]="trufflehog"
TOOL_SCRIPT_NAMES["ArgoCD_CLI"]="argocd_cli"
TOOL_SCRIPT_NAMES["Flux_CLI"]="flux_cli"
TOOL_SCRIPT_NAMES["Kubectx_Kubens"]="kubectx_kubens"
TOOL_SCRIPT_NAMES["Velero"]="velero"
TOOL_SCRIPT_NAMES["Grafana_Alloy"]="grafana_alloy"
TOOL_SCRIPT_NAMES["cAdvisor"]="cadvisor"
TOOL_SCRIPT_NAMES["Node_Exporter"]="node_exporter"
TOOL_SCRIPT_NAMES["DuckDB"]="duckdb"
TOOL_SCRIPT_NAMES["JupyterLab"]="jupyterlab"
TOOL_SCRIPT_NAMES["Airbyte"]="airbyte"
TOOL_SCRIPT_NAMES["Metabase"]="metabase"
TOOL_SCRIPT_NAMES["dbt"]="dbt"
TOOL_SCRIPT_NAMES["Apache_Tika"]="apache_tika"
TOOL_SCRIPT_NAMES["Docling"]="docling"
TOOL_SCRIPT_NAMES["Pandoc"]="pandoc"
TOOL_SCRIPT_NAMES["OCRmyPDF"]="ocrmypdf"
TOOL_SCRIPT_NAMES["Paperless_NGX"]="paperless_ngx"
TOOL_SCRIPT_NAMES["Stirling_PDF"]="stirling_pdf"
TOOL_SCRIPT_NAMES["Whisper_CPP"]="whisper_cpp"
TOOL_SCRIPT_NAMES["Faster_Whisper"]="faster_whisper"
TOOL_SCRIPT_NAMES["openWakeWord"]="openwakeword"
TOOL_SCRIPT_NAMES["Rhasspy"]="rhasspy"
TOOL_SCRIPT_NAMES["Wyoming"]="wyoming"
TOOL_SCRIPT_NAMES["Tesseract"]="tesseract"
TOOL_SCRIPT_NAMES["Marker"]="marker"
TOOL_SCRIPT_NAMES["LibreOffice_Headless"]="libreoffice_headless"
TOOL_SCRIPT_NAMES["RIFE"]="rife"
TOOL_SCRIPT_NAMES["Fooocus"]="fooocus"
TOOL_SCRIPT_NAMES["InvokeAI"]="invokeai"
TOOL_SCRIPT_NAMES["Blender"]="blender"
TOOL_SCRIPT_NAMES["Foundry"]="foundry"
TOOL_SCRIPT_NAMES["Hardhat"]="hardhat"
TOOL_SCRIPT_NAMES["Ethers_JS"]="ethers_js"
TOOL_SCRIPT_NAMES["Web3_Py"]="web3_py"
TOOL_SCRIPT_NAMES["OPA"]="opa"
TOOL_SCRIPT_NAMES["Meilisearch"]="meilisearch"
TOOL_SCRIPT_NAMES["Joplin_CLI"]="joplin_cli"
TOOL_SCRIPT_NAMES["Syncthing"]="syncthing"
TOOL_SCRIPT_NAMES["SQLite_Vec"]="sqlite_vec"
TOOL_SCRIPT_NAMES["Release_Please"]="release_please"
TOOL_SCRIPT_NAMES["Changelog_Generator"]="changelog_generator"
TOOL_SCRIPT_NAMES["Pgvector"]="pgvector"
TOOL_SCRIPT_NAMES["Prefect"]="prefect"
TOOL_SCRIPT_NAMES["Unstructured"]="unstructured"
TOOL_SCRIPT_NAMES["Home_Assistant"]="home_assistant"
TOOL_SCRIPT_NAMES["Restic"]="restic"
TOOL_SCRIPT_NAMES["Rclone"]="rclone"
TOOL_SCRIPT_NAMES["Syft"]="syft"
TOOL_SCRIPT_NAMES["Grype"]="grype"
TOOL_SCRIPT_NAMES["Semgrep"]="semgrep"
TOOL_SCRIPT_NAMES["Mosquitto"]="mosquitto"
TOOL_SCRIPT_NAMES["Node_Red"]="node_red"
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

remove_tool_from_autostart_script() {
    local tool_key="$1"
    local autostart_script="$USER_WORKSPACE_DIR/autostart/start_selected_tools.sh"
    local remaining_count=0

    [ -f "$autostart_script" ] || return 0

    python3 - "$tool_key" "$autostart_script" <<'PY'
from pathlib import Path
import re
import sys

tool = sys.argv[1]
path = Path(sys.argv[2])
text = path.read_text(encoding="utf-8")
lines = text.splitlines()
removed = False
remaining = 0
output = []

tool_line_pattern = re.compile(r'^\s*"([^"]+)"\s*$')

for line in lines:
    match = tool_line_pattern.match(line)
    if match:
        current_tool = match.group(1)
        if current_tool == tool:
            removed = True
            continue
        remaining += 1
    output.append(line)

if removed:
    path.write_text("\n".join(output).rstrip() + "\n", encoding="utf-8")
PY

    remaining_count="$(python3 - "$autostart_script" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
if not path.exists():
    print(0)
    raise SystemExit

count = 0
for line in path.read_text(encoding="utf-8").splitlines():
    if re.match(r'^\s*"[^"]+"\s*$', line):
        count += 1
print(count)
PY
)"

    if [ "$remaining_count" -eq 0 ] 2>/dev/null; then
        rm -f "$autostart_script"
        echo -e "${YELLOW}Autostart-Skript entfernt, weil kein Startziel mehr eingetragen ist.${NC}"
    else
        echo -e "${YELLOW}Autostart bereinigt: ${tool_key} wurde aus ${autostart_script} ausgetragen.${NC}"
    fi
}

# Funktion zum Installieren eines Tools
install_tool() {
    local TOOL_KEY="$1"
    if [ "$TOOL_KEY" = "Huginn" ]; then
        reset_terminal_display
        echo -e "${YELLOW}Huginn Vorbereitung: Zuerst Version und Datenbank auswählen, danach startet die Installation.${NC}"
        if ! bash "$INSTALL_DIR/scripts/huginn_config_manager.sh" --prepare-install; then
            reset_terminal_display
            echo -e "${YELLOW}Huginn-Installation wurde vor dem Start abgebrochen.${NC}"
            return 1
        fi
        reset_terminal_display
    fi

    show_tool_action_intro "$TOOL_KEY" "installieren" "install"
    begin_operation_measurement "tool_install_${TOOL_KEY}" "Tool installieren: ${TOOL_KEY}"
    echo -e "${BLUE}Installiere Tool: ${TOOL_KEY}...${NC}"
    if [ "$TOOL_KEY" = "Huginn" ]; then
        echo -e "${YELLOW}Huginn nutzt die Benutzerkonfiguration aus ~/.openclaw_ultimate_user_data/huginn/.${NC}"
        echo -e "${YELLOW}Dort liegen HUGINN_REPO_REF, Datenbankauswahl und .env.template bewusst ausserhalb des Repos.${NC}"
    fi
    run_tool_script "$TOOL_KEY" "install"
    if [ $? -eq 0 ]; then
        append_unique_line "$TOOL_STATUS_FILE" "$TOOL_KEY"
        end_operation_measurement "success"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich installiert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Installation von Tool \'$TOOL_KEY\'.${NC}"
    fi
    handle_manual_tool_post_action "$TOOL_KEY" "Installation"
}

# Funktion zum Deinstallieren eines Tools
uninstall_tool() {
    local TOOL_KEY="$1"
    show_tool_action_intro "$TOOL_KEY" "deinstallieren" "uninstall"
    begin_operation_measurement "tool_uninstall_${TOOL_KEY}" "Tool deinstallieren: ${TOOL_KEY}"
    echo -e "${BLUE}Deinstalliere Tool: ${TOOL_KEY}...${NC}"
    run_tool_script "$TOOL_KEY" "uninstall"
    if [ $? -eq 0 ]; then
        remove_exact_line "$TOOL_STATUS_FILE" "$TOOL_KEY"
        remove_tool_from_autostart_script "$TOOL_KEY"
        end_operation_measurement "success"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich deinstalliert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Deinstallation von Tool \'$TOOL_KEY\'.${NC}"
    fi
    handle_manual_tool_post_action "$TOOL_KEY" "Deinstallation"
}

# Funktion zum Anzeigen des Tool-Management-Menüs
show_tool_management_menu() {
    TOOL_BATCH_ABORT_REQUESTED=0
    sync_core_tool_status
    ensure_user_workspace
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"

    # Installierte Tools laden
    declare -A INSTALLED_TOOLS_MAP
    local total_tool_count=0
    local installed_tool_count=0
    load_installed_map "$TOOL_STATUS_FILE" INSTALLED_TOOLS_MAP
    total_tool_count="${#TOOL_KEYS[@]}"

    TOOL_CHECKLIST_OPTIONS=()
    for tool_key in "${TOOL_KEYS[@]}"; do
        STATUS="off"
        if [ -n "$tool_key" ] && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" = "1" ]; then
            STATUS="on"
            installed_tool_count=$((installed_tool_count + 1))
        fi
        TOOL_CHECKLIST_OPTIONS+=("$tool_key" "${TOOLS[$tool_key]}" "$STATUS")
    done

    dialog --clear --backtitle "$APP_TITLE" \
    --title "TOOL-MANAGEMENT (${installed_tool_count}/${total_tool_count} installiert)" --checklist "Wählen Sie Tools zum Installieren/Deinstallieren. Gesamt: ${total_tool_count} | Installiert: ${installed_tool_count}" 32 110 24 \
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
            if [ "${TOOL_BATCH_ABORT_REQUESTED:-0}" = "1" ]; then
                return 0
            fi
        elif ! selection_contains "$tool_key" "${SELECTED_TOOLS_ARRAY[@]}" && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" = "1" ]; then
            # Tool nicht ausgewählt und installiert -> Deinstallieren
            uninstall_tool "$tool_key"
            if [ "${TOOL_BATCH_ABORT_REQUESTED:-0}" = "1" ]; then
                return 0
            fi
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

PROFILE_CORE_TOOLS["Ethical_HackerGPT"]="Nmap Trivy Gitleaks Semgrep Syft Grype Fail2Ban"
PROFILE_EXTENDED_TOOLS["Ethical_HackerGPT"]="GitHub_CLI Docker Kubernetes"
PROFILE_INTEGRATION_TOOLS["Ethical_HackerGPT"]="OpenTelemetry"

PROFILE_CORE_TOOLS["Trading_AI"]="Zenbot_trader Web3_APIs Exchange_APIs"
PROFILE_EXTENDED_TOOLS["Trading_AI"]="Zenbot_API Risk_Strategy_Analyzer Backtest_Workflow FinGPT FinRobot FinRAG"
PROFILE_INTEGRATION_TOOLS["Trading_AI"]=""

PROFILE_CORE_TOOLS["Visual_Creator"]="FFmpeg Stable_Diffusion_WebUI ComfyUI RealESRGAN"
PROFILE_EXTENDED_TOOLS["Visual_Creator"]="AnimateDiff SVD Runway_API Image_Upscaler_Pipeline"
PROFILE_INTEGRATION_TOOLS["Visual_Creator"]=""

PROFILE_CORE_TOOLS["LLM_Builder"]="Ollama Data_Juicer Unsloth LLaMA_Factory Llama_CPP_Toolchain"
PROFILE_EXTENDED_TOOLS["LLM_Builder"]="Axolotl MLflow Weights_and_Biases vLLM Llama_CPP"
PROFILE_INTEGRATION_TOOLS["LLM_Builder"]="OpenClaw Flowise LangFlow Huginn Clawbake Docker Code_Sandbox GitHub_CLI ChromaDB"
PROFILE_SPECIAL_TOOLS["LLM_Builder"]="Ollama Data_Juicer Unsloth LLaMA_Factory Llama_CPP_Toolchain Axolotl MLflow Weights_and_Biases vLLM Llama_CPP OpenClaw Flowise LangFlow Huginn Clawbake Docker Code_Sandbox GitHub_CLI ChromaDB"
PROFILE_SPECIAL_LABELS["LLM_Builder"]="LLM-Builder komplett"

PROFILE_CORE_TOOLS["DevOps_SRE"]="Ansible OpenTofu Helm K9s Uptime_Kuma Grafana_Alloy cAdvisor Node_Exporter"
PROFILE_EXTENDED_TOOLS["DevOps_SRE"]="ArgoCD_CLI Flux_CLI Kubectx_Kubens Velero Restic Rclone Docker_Compose_Plugin"
PROFILE_INTEGRATION_TOOLS["DevOps_SRE"]="Docker Kubernetes K3s Prometheus Grafana Loki Healthchecks"

PROFILE_CORE_TOOLS["Data_Engineering"]="DuckDB Prefect MinIO Postgres Pgvector Qdrant Apache_Tika Unstructured Pandoc"
PROFILE_EXTENDED_TOOLS["Data_Engineering"]="Metabase Airbyte dbt JupyterLab Docling"
PROFILE_INTEGRATION_TOOLS["Data_Engineering"]="Ollama ChromaDB LangChain LlamaIndex"

PROFILE_CORE_TOOLS["Document_AI"]="OCRmyPDF Tesseract Stirling_PDF Paperless_NGX Apache_Tika Docling Marker Pandoc"
PROFILE_EXTENDED_TOOLS["Document_AI"]="LibreOffice_Headless"
PROFILE_INTEGRATION_TOOLS["Document_AI"]="Qdrant Open_WebUI ChromaDB"

PROFILE_CORE_TOOLS["Voice_Assistant"]="Whisper_CPP Faster_Whisper Piper openWakeWord Mosquitto"
PROFILE_EXTENDED_TOOLS["Voice_Assistant"]="Rhasspy Wyoming"
PROFILE_INTEGRATION_TOOLS["Voice_Assistant"]="Node_Red"

PROFILE_CORE_TOOLS["Video_Generation"]="ComfyUI Stable_Diffusion_WebUI_Forge SVD AnimateDiff RIFE RealESRGAN FFmpeg Blender"
PROFILE_EXTENDED_TOOLS["Video_Generation"]="ControlNet"
PROFILE_INTEGRATION_TOOLS["Video_Generation"]="YT_DLP Thumbnail_Pipeline"

PROFILE_CORE_TOOLS["Image_Generation"]="ComfyUI Stable_Diffusion_WebUI_Forge Fooocus InvokeAI RealESRGAN"
PROFILE_EXTENDED_TOOLS["Image_Generation"]="ControlNet GFPGAN Rembg"
PROFILE_INTEGRATION_TOOLS["Image_Generation"]="Image_Upscaler_Pipeline"

PROFILE_CORE_TOOLS["Web3_Crypto_Tools"]="Foundry Hardhat Ethers_JS Web3_Py"
PROFILE_EXTENDED_TOOLS["Web3_Crypto_Tools"]="Web3_APIs Exchange_APIs"
PROFILE_INTEGRATION_TOOLS["Web3_Crypto_Tools"]="GitHub_CLI"

PROFILE_CORE_TOOLS["Compliance_Privacy"]="OPA Gitleaks TruffleHog Syft Grype Trivy Semgrep"
PROFILE_EXTENDED_TOOLS["Compliance_Privacy"]="Promptfoo Guardrails_AI"
PROFILE_INTEGRATION_TOOLS["Compliance_Privacy"]="OpenTelemetry"

PROFILE_CORE_TOOLS["Personal_Knowledge_OS"]="Joplin_CLI Meilisearch Qdrant SQLite_Vec Syncthing Rclone"
PROFILE_EXTENDED_TOOLS["Personal_Knowledge_OS"]="ChromaDB LangChain LlamaIndex"
PROFILE_INTEGRATION_TOOLS["Personal_Knowledge_OS"]="Open_WebUI Ollama"

PROFILE_CORE_TOOLS["Next_Level_Persona_System"]="Ollama OpenClaw Open_WebUI Qdrant ChromaDB"
PROFILE_EXTENDED_TOOLS["Next_Level_Persona_System"]="Piper Faster_Whisper ComfyUI Langfuse"
PROFILE_INTEGRATION_TOOLS["Next_Level_Persona_System"]="GitHub_CLI Docker"

PROFILE_CORE_TOOLS["Repo_Maintainer"]="GitHub_CLI Pre_Commit Act Markdownlint_CLI ShellCheck Shfmt Hadolint Actionlint Release_Please Changelog_Generator"
PROFILE_EXTENDED_TOOLS["Repo_Maintainer"]="Gitleaks Docker_Compose_Plugin"
PROFILE_INTEGRATION_TOOLS["Repo_Maintainer"]="Docker"

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
        if [ "${PROFILE_FLOW_ABORT_REQUESTED:-0}" = "1" ]; then
            return 0
        fi
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
        if [ "${PROFILE_FLOW_ABORT_REQUESTED:-0}" = "1" ]; then
            return 0
        fi
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
    local menu_rows=16
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
    "----" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
    "4" "${TXT_MENU_4:-Hybrid: Dein MiniPC + Multi-VPS (Empfohlen)}" \
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
    "13" "${TXT_MENU_13:-Home Assistant starten}" \
    "14" "${TXT_MENU_14:-Installierte Dienste starten}" 2> /tmp/menu_choice

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
            "$(get_operation_duration_estimate_label "main_menu_update" "${UBUNTU_UPDATES_DOWNLOAD_TIME_ESTIMATE} Download + ${UBUNTU_UPDATES_INSTALL_TIME_ESTIMATE} Installation")" \
            "$(get_operation_storage_estimate_label "main_menu_update" "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB")" \
            "Bei lokalen Aenderungen im Setup wird das Repo-Update bewusst uebersprungen, damit nichts ueberschrieben wird."
            begin_operation_measurement "main_menu_update" "Setup-Update + System-Update"
            run_bash_script "$INSTALL_DIR/scripts/auto_update.sh"
            if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            read -p "System-Update abgeschlossen. Drücken Sie Enter..."
            ;;
        2)
            show_operation_intro \
            "Ollama Modell-Manager" \
            "Lokales LLM-Backend. Du kannst über den Ollama Modell-Manager spezifische Modelle installieren und verwalten. Für weitere Informationen zu den Modellen siehe in der Online-Dokumentation nach." \
            "Modell-Downloads und Installationszeiten werden im Modell-Manager je Modell gemessen und spaeter fuer reale Erfahrungswerte gespeichert" \
            "15-40 GB ohne Modelle, mit mehreren Modellen deutlich mehr" \
            "Die eigentliche Dauer haengt stark von Modellgroesse, Internetgeschwindigkeit und SSD-Leistung ab."
            run_bash_script "$INSTALL_DIR/scripts/ollama_model_manager.sh"
            read -p "Ollama Modell-Management abgeschlossen. Drücken Sie Enter..."
            ;;
        3)
            run_bash_script "$INSTALL_DIR/scripts/openclaw_config_manager.sh"
            read -p "OpenClaw Konfiguration abgeschlossen. Drücken Sie Enter..."
            ;;
        4)
            show_operation_intro \
            "Hybrid-Setup: Dein MiniPC + Multi-VPS" \
            "Installiert zuerst die Basis mit OpenClaw und Ollama und richtet danach das hybride Setup mit Home Assistant und Cloudflare-nahem Zugriff ein." \
            "$(get_operation_duration_estimate_label "main_menu_hybrid" "${SETUP_INSTALL_TIME_ESTIMATE} Gesamt, darin meist ${OPENCLAW_DOWNLOAD_TIME_ESTIMATE} Download + ${OPENCLAW_BUILD_TIME_ESTIMATE} Build + ${OLLAMA_INSTALL_TIME_ESTIMATE} fuer Ollama + ${HOME_ASSISTANT_INSTALL_TIME_ESTIMATE} fuer Home Assistant")" \
            "$(get_operation_storage_estimate_label "main_menu_hybrid" "${MIN_FREE_GB_RECOMMENDED} GB oder mehr")" \
            "Je nach Cloudflare- und VPS-Schritten koennen weitere manuelle Angaben oder API-Daten noetig sein."
            begin_operation_measurement "main_menu_hybrid" "Hybrid-Setup: Dein MiniPC + Multi-VPS"
            echo -e "${BLUE}Starte Hybrid-Setup (Dein MiniPC + Multi-VPS)...${NC}"
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
            "$(get_operation_duration_estimate_label "main_menu_vps" "${SETUP_INSTALL_TIME_ESTIMATE} Gesamt, darin meist ${OPENCLAW_DOWNLOAD_TIME_ESTIMATE} Download + ${OPENCLAW_BUILD_TIME_ESTIMATE} Build + ${OLLAMA_INSTALL_TIME_ESTIMATE} fuer Ollama")" \
            "$(get_operation_storage_estimate_label "main_menu_vps" "${MIN_FREE_GB_RECOMMENDED} GB oder mehr")" \
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
            "$(get_operation_duration_estimate_label "main_menu_local" "${LOCAL_SETUP_TOTAL_ESTIMATE} Gesamt, darin meist ${OPENCLAW_DOWNLOAD_TIME_ESTIMATE} Download + ${OPENCLAW_BUILD_TIME_ESTIMATE} Build + ${OLLAMA_INSTALL_TIME_ESTIMATE} fuer Ollama + ${HOME_ASSISTANT_INSTALL_TIME_ESTIMATE} fuer Home Assistant")" \
            "$(get_operation_storage_estimate_label "main_menu_local" "${MIN_FREE_GB_RECOMMENDED} GB oder mehr")" \
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
            "$(get_operation_duration_estimate_label "main_menu_ruflo" "${SETUP_DOWNLOAD_TIME_ESTIMATE} Download + ${SETUP_INSTALL_TIME_ESTIMATE} Installation")" \
            "$(get_operation_storage_estimate_label "main_menu_ruflo" "${MIN_FREE_GB_ABSOLUTE} GB oder mehr")" \
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
            "$(get_operation_duration_estimate_label "main_menu_openclaw_dev" "Start meist in wenigen Sekunden bis Minuten, je nach vorhandenem Build-Stand")" \
            "$(get_operation_storage_estimate_label "main_menu_openclaw_dev" "${MIN_FREE_GB_ABSOLUTE} GB oder mehr")" \
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
            "$(get_operation_duration_estimate_label "main_menu_homeassistant" "${HOME_ASSISTANT_INSTALL_TIME_ESTIMATE} fuer Erstaufbau, Start selbst meist deutlich kuerzer")" \
            "$(get_operation_storage_estimate_label "main_menu_homeassistant" "${MIN_FREE_GB_ABSOLUTE} GB oder mehr")" \
            "Wenn Home Assistant noch nicht eingerichtet wurde, nutze vorher ein passendes Setup mit lokaler oder hybrider Installation."
            begin_operation_measurement "main_menu_homeassistant" "Home Assistant starten"
            echo -e "${BLUE}Starte Home Assistant...${NC}"
            sudo systemctl start homeassistant@homeassistant
            if [ $? -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            ;;
        14)
            show_operation_intro \
            "Installierte Dienste starten" \
            "Oeffnet den zentralen Start-Manager fuer aktuell installierte und im Setup hinterlegte Startziele. Dort kannst du alle oder nur ausgewaehlte Tools starten und ein anpassbares Autostart-Skript erzeugen." \
            "$(get_operation_duration_estimate_label "main_menu_start_manager" "Menue oeffnet sofort, eigentliche Starts je nach Tool in Sekunden bis wenigen Minuten")" \
            "$(get_operation_storage_estimate_label "main_menu_start_manager" "${MIN_FREE_GB_ABSOLUTE} GB oder mehr fuer Logs und Runtime-Dateien")" \
            "Falls du einen Autostart spaeter abbrechen willst, kann das erzeugte Skript dich direkt wieder ins Setup zurueckbringen."
            begin_operation_measurement "main_menu_start_manager" "Installierte Dienste starten"
            run_bash_script "$INSTALL_DIR/scripts/tool_start_manager.sh"
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
