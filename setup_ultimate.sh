#!/bin/bash
#
# Skript: setup_ultimate.sh
# Beschreibung: Dies ist das Hauptinstallationsskript für die ultimative KI-Infrastruktur.
# Es bietet eine interaktive Menüführung zur Installation, Deinstallation und Verwaltung verschiedener KI-Tools, Profile und Systemkomponenten.
# Das Skript unterstützt hybride Setups (MiniPC + Multi-VPS), Standalone-Installationen und bietet Funktionen wie Auto-Updates, Ollama-Modellverwaltung und OpenClaw-Konfiguration.
# Version: V11.17
#

# Farben & UI
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"
NC="\033[0m"
APP_VERSION="11.17"
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
METRICS_SUMMARY_FILE="$USER_METRICS_LOG_DIR/operation_summary.tsv"
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
    if [ ! -f "$METRICS_SUMMARY_FILE" ]; then
        printf 'operation_id\tduration_seconds\tdelta_kb\ttimestamp\n' > "$METRICS_SUMMARY_FILE"
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
N8N_TOOL_DURATION_ESTIMATE="10-45 min Klonen + GitHub-Monorepo-Build"
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
PHYSIK_REQUIRED_GB="8-30"
CHEMIE_REQUIRED_GB="10-40"
BIOLOGIE_REQUIRED_GB="10-40"
BIOINFORMATIK_REQUIRED_GB="15-60"
MOLEKUELSIMULATION_REQUIRED_GB="20-120"
ROBOTIK_LABOR_REQUIRED_GB="12-60"
MATERIALWISSENSCHAFT_REQUIRED_GB="15-80"
MATHEMATIK_SIMULATION_REQUIRED_GB="5-20"
ASTRONOMIE_SPACE_AI_REQUIRED_GB="10-40"
MEDIZINISCHE_LITERATUR_RECHERCHE_REQUIRED_GB="8-30"
UMWELT_KLIMA_ENERGIE_REQUIRED_GB="8-30"
PERSONAL_ASSISTANT_LOCAL_FIRST_REQUIRED_GB="15-50"
VOICE_COMMAND_CENTER_REQUIRED_GB="10-40"
KNOWLEDGE_LIBRARIAN_REQUIRED_GB="15-80"
WEB_APP_BUILDER_REQUIRED_GB="8-25"
ZERO_TRUST_REMOTE_ACCESS_REQUIRED_GB="3-10"
KUBERNETES_GPU_ORCHESTRATOR_REQUIRED_GB="20-80"
STORAGE_NAS_BACKUP_REQUIRED_GB="20-200"
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

# Quellen- und Speicherpolitik:
# Standard: Tool-Installer sollen ihre Primaerquelle aus GitHub beziehen.
# Systempakete wie apt-Abhaengigkeiten bleiben als Basisabhaengigkeiten erlaubt.
# Wenn STRICT_GITHUB_TOOL_SOURCES=true gesetzt wird, blockiert das Setup Tool-Installer,
# deren Skript keine GitHub-Quelle erkennen laesst. Einzelne Ausnahmen koennen bewusst
# per ALLOW_NON_GITHUB_TOOL_SOURCE=1 gestartet werden.
GITHUB_TOOL_SOURCES_PREFERRED="true"
STRICT_GITHUB_TOOL_SOURCES="false"
ALLOW_NON_GITHUB_TOOL_SOURCE="false"
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

set_log_cleanup_mode() {
    local enabled="$1"

    enabled="$(normalize_setup_boolean "$enabled")"
    persist_setup_preference "LOG_CLEANUP_BEFORE_OPERATION" "$enabled"
    load_setup_language
}

set_overview_metrics_mode() {
    local enabled="$1"

    enabled="$(normalize_setup_boolean "$enabled")"
    persist_setup_preference "OVERVIEW_METRICS_ENABLED" "$enabled"
    load_setup_language
}

set_menu_loading_notice_mode() {
    local enabled="$1"

    enabled="$(normalize_setup_boolean "$enabled")"
    persist_setup_preference "MENU_LOADING_NOTICE_ENABLED" "$enabled"
    load_setup_language
}

set_log_cleanup_number_preference() {
    local key="$1"
    local value="$2"

    case "$value" in
        ''|*[!0-9]*)
            echo -e "${RED}Fehler: '$value' ist keine gültige Zahl.${NC}"
            return 1
            ;;
    esac

    persist_setup_preference "$key" "$value"
    load_setup_language
}

reset_terminal_display() {
    printf '\033[0m'
    tput sgr0 2>/dev/null || true
}

get_free_disk_kb() {
    df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}'
}

get_free_disk_gb() {
    local free_kb
    free_kb="$(get_free_disk_kb)"
    if [ -n "$free_kb" ]; then
        printf '%s' $((free_kb / 1024 / 1024))
    else
        printf '0'
    fi
}

is_wsl_environment() {
    grep -qi microsoft /proc/version 2>/dev/null || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

get_windows_host_free_kb() {
    local drive_name="${WINDOWS_HOST_DRIVE:-C}"
    local free_bytes

    command -v powershell.exe >/dev/null 2>&1 || return 0
    free_bytes="$(powershell.exe -NoProfile -Command "(Get-PSDrive -Name '${drive_name}').Free" 2>/dev/null | tr -d '\r' | awk 'NF {print int($1); exit}')"
    if [ -n "$free_bytes" ] && [ "$free_bytes" -gt 0 ] 2>/dev/null; then
        printf '%s' $((free_bytes / 1024))
    fi
}

show_wsl_windows_space_warning() {
    local windows_free_kb
    local absolute_min_kb

    is_wsl_environment || return 0
    windows_free_kb="$(get_windows_host_free_kb)"
    [ -n "$windows_free_kb" ] || return 0

    echo -e "${YELLOW}Freier Windows-Host-Speicher (${WINDOWS_HOST_DRIVE:-C}:):${NC} ${GREEN}$(format_kb_human "$windows_free_kb")${NC}"
    echo -e "${YELLOW}Hinweis:${NC} Die WSL-Zahl oben ist die freie Kapazitaet im Linux-Dateisystem bzw. Mountpoint, nicht automatisch die freie Kapazitaet deiner gesamten Windows-Festplatten. Wenn WSL auf ${WINDOWS_HOST_DRIVE:-C}: liegt, begrenzt der Windows-Host-Speicher praktisch, wie stark die WSL-VHDX noch wachsen kann."

    absolute_min_kb=$(( ${MIN_FREE_GB_ABSOLUTE:-50} * 1024 * 1024 ))
    if [ "$windows_free_kb" -lt "$absolute_min_kb" ] 2>/dev/null; then
        echo -e "${RED}Warnung:${NC} Windows meldet weniger als ${MIN_FREE_GB_ABSOLUTE:-50} GB frei. Grosse Installationen koennen scheitern oder Windows/WSL instabil machen."
    fi
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

format_duration_hhmmss() {
    local total_seconds="${1:-}"

    if ! [[ "$total_seconds" =~ ^[0-9]+$ ]]; then
        printf '%s' "--:--:--"
        return 0
    fi

    printf '%02d:%02d:%02d' \
        "$((total_seconds / 3600))" \
        "$(((total_seconds % 3600) / 60))" \
        "$((total_seconds % 60))"
}

highlight_time_value() {
    local value="$1"
    printf '%b%s%b' "$WHITE" "$value" "$NC"
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

format_kb_mb_value() {
    local total_kb="${1:-}"

    if ! [[ "$total_kb" =~ ^-?[0-9]+$ ]]; then
        printf '%s' "--.- MB"
        return 0
    fi

    awk -v kb="$total_kb" 'BEGIN {printf "%.1f MB", kb/1024}'
}

declare -A METRIC_CACHE_DURATION_SECONDS
declare -A METRIC_CACHE_DELTA_KB
METRIC_CACHE_LOADED=0

rebuild_metric_summary_cache() {
    ensure_user_workspace
    if [ ! -f "$METRICS_HISTORY_FILE" ]; then
        printf 'operation_id\tduration_seconds\tdelta_kb\ttimestamp\n' > "$METRICS_SUMMARY_FILE"
        return 0
    fi

    awk -F'\t' '
        NR == 1 && $2 == "operation_id" { next }
        $4 == "success" && $2 != "" {
            duration[$2] = $5
            delta[$2] = $8
            ts[$2] = $1
        }
        END {
            print "operation_id\tduration_seconds\tdelta_kb\ttimestamp"
            for (id in duration) {
                print id "\t" duration[id] "\t" delta[id] "\t" ts[id]
            }
        }
    ' "$METRICS_HISTORY_FILE" > "$METRICS_SUMMARY_FILE"
}

load_metric_cache_once() {
    local timestamp
    local operation_id
    local operation_title
    local status
    local duration_seconds
    local free_kb_before
    local free_kb_after
    local delta_kb

    if [ "${METRIC_CACHE_LOADED:-0}" = "1" ]; then
        return 0
    fi

    METRIC_CACHE_DURATION_SECONDS=()
    METRIC_CACHE_DELTA_KB=()
    ensure_user_workspace
    if [ ! -s "$METRICS_SUMMARY_FILE" ] || [ "$(wc -l < "$METRICS_SUMMARY_FILE" 2>/dev/null || echo 0)" -le 1 ]; then
        rebuild_metric_summary_cache
    fi

    if [ -f "$METRICS_SUMMARY_FILE" ]; then
        while IFS=$'\t' read -r operation_id duration_seconds delta_kb timestamp; do
            [ "$operation_id" != "operation_id" ] || continue
            [ -n "$operation_id" ] || continue
            METRIC_CACHE_DURATION_SECONDS["$operation_id"]="$duration_seconds"
            METRIC_CACHE_DELTA_KB["$operation_id"]="$delta_kb"
        done < "$METRICS_SUMMARY_FILE"
    fi
    METRIC_CACHE_LOADED=1
}

invalidate_metric_cache() {
    METRIC_CACHE_LOADED=0
}

get_last_success_metric_field() {
    local operation_id="$1"
    local field_index="$2"

    load_metric_cache_once
    case "$field_index" in
        5)
            printf '%s' "${METRIC_CACHE_DURATION_SECONDS[$operation_id]:-}"
            ;;
        8)
            printf '%s' "${METRIC_CACHE_DELTA_KB[$operation_id]:-}"
            ;;
        *)
            return 1
            ;;
    esac
}

get_operation_metric_summary_plain() {
    local operation_id="$1"
    local duration_seconds
    local delta_kb

    duration_seconds="$(get_last_success_metric_field "$operation_id" 5)"
    delta_kb="$(get_last_success_metric_field "$operation_id" 8)"

    printf '%s | %s' "$(format_duration_hhmmss "$duration_seconds")" "$(format_kb_mb_value "$delta_kb")"
}

summarize_operation_metrics_plain() {
    local operation_kind="$1"
    shift
    local total_seconds=0
    local total_kb=0
    local missing_duration=0
    local missing_storage=0
    local item
    local operation_id
    local duration_seconds
    local delta_kb

    for item in "$@"; do
        [ -n "$item" ] || continue
        operation_id="${operation_kind}_${item}"
        duration_seconds="$(get_last_success_metric_field "$operation_id" 5)"
        delta_kb="$(get_last_success_metric_field "$operation_id" 8)"

        if [[ "$duration_seconds" =~ ^[0-9]+$ ]]; then
            total_seconds=$((total_seconds + duration_seconds))
        else
            missing_duration=1
        fi

        if [[ "$delta_kb" =~ ^-?[0-9]+$ ]]; then
            total_kb=$((total_kb + delta_kb))
        else
            missing_storage=1
        fi
    done

    if [ "$missing_duration" -eq 1 ]; then
        printf '%s' "--:--:--"
    else
        format_duration_hhmmss "$total_seconds"
    fi
    printf ' | '
    if [ "$missing_storage" -eq 1 ]; then
        printf '%s' "--.- MB"
    else
        format_kb_mb_value "$total_kb"
    fi
}

summarize_operation_metrics_with_missing_plain() {
    local operation_kind="$1"
    shift
    local total_seconds=0
    local total_kb=0
    local missing_duration=0
    local missing_storage=0
    local item
    local operation_id
    local duration_seconds
    local delta_kb

    for item in "$@"; do
        [ -n "$item" ] || continue
        operation_id="${operation_kind}_${item}"
        duration_seconds="$(get_last_success_metric_field "$operation_id" 5)"
        delta_kb="$(get_last_success_metric_field "$operation_id" 8)"

        if [[ "$duration_seconds" =~ ^[0-9]+$ ]]; then
            total_seconds=$((total_seconds + duration_seconds))
        else
            missing_duration=$((missing_duration + 1))
        fi

        if [[ "$delta_kb" =~ ^-?[0-9]+$ ]]; then
            total_kb=$((total_kb + delta_kb))
        else
            missing_storage=$((missing_storage + 1))
        fi
    done

    if [ "$missing_duration" -gt 0 ]; then
        printf '%s' "--:--:--"
    else
        format_duration_hhmmss "$total_seconds"
    fi
    printf ' | '
    if [ "$missing_storage" -gt 0 ]; then
        printf '%s' "--.- MB"
    else
        format_kb_mb_value "$total_kb"
    fi
    printf ' (fehlend: Zeit %s, Speicher %s)' "$missing_duration" "$missing_storage"
}

summarize_tool_batch_metrics_plain() {
    local -n uninstall_ref="$1"
    local -n install_ref="$2"
    local total_seconds=0
    local total_kb=0
    local missing_duration=0
    local missing_storage=0
    local item
    local operation_id
    local duration_seconds
    local delta_kb

    for item in "${uninstall_ref[@]}"; do
        [ -n "$item" ] || continue
        operation_id="tool_uninstall_${item}"
        duration_seconds="$(get_last_success_metric_field "$operation_id" 5)"
        delta_kb="$(get_last_success_metric_field "$operation_id" 8)"
        if [[ "$duration_seconds" =~ ^[0-9]+$ ]]; then
            total_seconds=$((total_seconds + duration_seconds))
        else
            missing_duration=1
        fi
        if [[ "$delta_kb" =~ ^-?[0-9]+$ ]]; then
            total_kb=$((total_kb + delta_kb))
        else
            missing_storage=1
        fi
    done

    for item in "${install_ref[@]}"; do
        [ -n "$item" ] || continue
        operation_id="tool_install_${item}"
        duration_seconds="$(get_last_success_metric_field "$operation_id" 5)"
        delta_kb="$(get_last_success_metric_field "$operation_id" 8)"
        if [[ "$duration_seconds" =~ ^[0-9]+$ ]]; then
            total_seconds=$((total_seconds + duration_seconds))
        else
            missing_duration=1
        fi
        if [[ "$delta_kb" =~ ^-?[0-9]+$ ]]; then
            total_kb=$((total_kb + delta_kb))
        else
            missing_storage=1
        fi
    done

    if [ "$missing_duration" -eq 1 ]; then
        printf '%s' "--:--:--"
    else
        format_duration_hhmmss "$total_seconds"
    fi
    printf ' | '
    if [ "$missing_storage" -eq 1 ]; then
        printf '%s' "--.- MB"
    else
        format_kb_mb_value "$total_kb"
    fi
}

get_operation_duration_estimate_label() {
    local operation_id="$1"
    local fallback_label="$2"
    local duration_seconds

    duration_seconds="$(get_last_success_metric_field "$operation_id" 5)"
    if [ -n "$duration_seconds" ]; then
        printf '%s %s' "$(highlight_time_value "$(format_duration_human "$duration_seconds")")" "${YELLOW}(letzte erfolgreiche Messung)${NC}"
    else
        highlight_time_value "$fallback_label"
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
        "n8n") printf '10-45 min Klonen + GitHub-Monorepo-Build' ;;
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

operation_id_to_metric_prefix() {
    local operation_id="$1"

    printf '%s' "$operation_id" | tr '[:lower:]- /.' '[:upper:]____'
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

get_tool_install_measured_mb() {
    local tool_key="$1"
    local delta_kb

    delta_kb="$(get_last_success_metric_field "tool_install_${tool_key}" 8)"
    if [[ "$delta_kb" =~ ^[0-9]+$ ]] && [ "$delta_kb" -gt 0 ] 2>/dev/null; then
        printf '%s' "$(( (delta_kb + 1023) / 1024 ))"
    fi
}

get_tool_install_fallback_min_free_mb() {
    local tool_key="$1"

    case "$tool_key" in
        "Airbyte")
            printf '32768'
            ;;
        "ComfyUI"|"Stable_Diffusion_WebUI"|"Stable_Diffusion_WebUI_Forge"|"InvokeAI"|"Fooocus"|"Blender"|"AnimateDiff"|"RealESRGAN"|"GFPGAN"|"Wan_Video"|"SVD"*|*"Video"*|*"Image"*)
            printf '40960'
            ;;
        "AutoGPT"|"OpenHands"|"Activepieces"|"n8n"|"Clawhub"|"Clawhub_CLI"|"OpenManus"|"Kimi"*|"Ruflo")
            printf '16384'
            ;;
        "Ollama"|"Open_WebUI"|"Qdrant"|"ChromaDB"|"Meilisearch"|"Paperless"*|"Nextcloud")
            printf '8192'
            ;;
        "Docker"|"K3s"|"Kubernetes"*|"Grafana"|"Prometheus"|"Loki")
            printf '8192'
            ;;
        *)
            printf '4096'
            ;;
    esac
}

get_tool_install_min_free_mb() {
    local tool_key="$1"
    local measured_mb
    local fallback_mb
    local measured_guard_mb

    measured_mb="$(get_tool_install_measured_mb "$tool_key")"
    fallback_mb="$(get_tool_install_fallback_min_free_mb "$tool_key")"

    if [[ "$measured_mb" =~ ^[0-9]+$ ]] && [ "$measured_mb" -gt 0 ] 2>/dev/null; then
        measured_guard_mb=$((measured_mb + (measured_mb / 2) + 1024))
        if [ "$measured_guard_mb" -lt 2048 ] 2>/dev/null; then
            measured_guard_mb=2048
        fi
        if [ "$measured_guard_mb" -gt "$fallback_mb" ] 2>/dev/null; then
            printf '%s' "$measured_guard_mb"
        else
            printf '%s' "$fallback_mb"
        fi
    else
        printf '%s' "$fallback_mb"
    fi
}

get_tool_install_windows_min_free_mb() {
    local linux_min_mb="${1:-4096}"

    if [ "$linux_min_mb" -ge 40960 ] 2>/dev/null; then
        printf '30720'
    elif [ "$linux_min_mb" -ge 20480 ] 2>/dev/null; then
        printf '20480'
    elif [ "$linux_min_mb" -ge 8192 ] 2>/dev/null; then
        printf '10240'
    else
        printf '5120'
    fi
}

preflight_tool_install_storage() {
    local tool_key="$1"
    local min_mb
    local min_kb
    local free_kb
    local measured_mb
    local fallback_mb
    local windows_min_mb
    local windows_min_kb
    local windows_free_kb

    min_mb="$(get_tool_install_min_free_mb "$tool_key")"
    fallback_mb="$(get_tool_install_fallback_min_free_mb "$tool_key")"
    measured_mb="$(get_tool_install_measured_mb "$tool_key")"
    min_kb=$((min_mb * 1024))
    free_kb="$(get_free_disk_kb)"
    free_kb="${free_kb:-0}"

    echo -e "${YELLOW}Speicherplatz-Wache fuer ${tool_key}:${NC} mindestens $(format_kb_human "$min_kb") freier Linux-/WSL-Speicher vor dem Start."
    if [[ "$measured_mb" =~ ^[0-9]+$ ]] && [ "$measured_mb" -gt 0 ] 2>/dev/null; then
        echo -e "${YELLOW}Vorlage:${NC} letzte erfolgreiche Messung ${measured_mb} MB; Mindestwert mit Sicherheitsaufschlag und Tool-Fallback ${fallback_mb} MB."
    else
        echo -e "${YELLOW}Vorlage:${NC} noch kein erfolgreicher Messwert vorhanden; nutze konservativen Tool-Fallback ${fallback_mb} MB."
    fi
    echo -e "${YELLOW}Aktuell frei Linux/WSL:${NC} $(format_kb_human "$free_kb")"

    if [ "$free_kb" -lt "$min_kb" ] 2>/dev/null; then
        echo -e "${RED}Abbruch vor der Installation:${NC} Fuer ${tool_key} sind mindestens $(format_kb_human "$min_kb") frei empfohlen, aktuell sind nur $(format_kb_human "$free_kb") frei."
        echo -e "${YELLOW}Tipp:${NC} Erst Speicher freigeben, z. B. mit: bash scripts/cleanup_installation_residues.sh --apply --all"
        return 1
    fi

    if is_wsl_environment; then
        windows_min_mb="$(get_tool_install_windows_min_free_mb "$min_mb")"
        windows_min_kb=$((windows_min_mb * 1024))
        windows_free_kb="$(get_windows_host_free_kb)"
        if [ -n "$windows_free_kb" ]; then
            echo -e "${YELLOW}Aktuell frei Windows-Host (${WINDOWS_HOST_DRIVE:-C}:):${NC} ${GREEN}$(format_kb_human "$windows_free_kb")${NC}"
            if [ "$windows_free_kb" -lt "$windows_min_kb" ] 2>/dev/null; then
                echo -e "${RED}Abbruch vor der Installation:${NC} Unter WSL sollte ${WINDOWS_HOST_DRIVE:-C}: fuer ${tool_key} mindestens $(format_kb_human "$windows_min_kb") frei haben, aktuell sind nur $(format_kb_human "$windows_free_kb") frei."
                echo -e "${YELLOW}Grund:${NC} Die WSL-VHDX waechst auf dem Windows-Host. Wenn ${WINDOWS_HOST_DRIVE:-C}: voll laeuft, koennen Downloads, pip/npm/pnpm oder Docker-Images mit I/O-Fehlern abbrechen."
                return 1
            fi
        else
            echo -e "${YELLOW}Hinweis:${NC} Windows-Host-Speicher konnte nicht ermittelt werden. Linux-/WSL-Pruefung wurde trotzdem ausgefuehrt."
        fi
    fi

    return 0
}

begin_operation_measurement() {
    ensure_user_workspace
    ACTIVE_OPERATION_ID="$1"
    ACTIVE_OPERATION_TITLE="$2"
    ACTIVE_OPERATION_STARTED_AT="$(date +%s)"
    ACTIVE_OPERATION_FREE_KB_BEFORE="$(get_free_disk_kb)"
    echo -e "${YELLOW}Freier WSL-/Linux-Dateisystemspeicher vor Start:${NC} $(format_kb_human "${ACTIVE_OPERATION_FREE_KB_BEFORE:-0}")"
    show_wsl_windows_space_warning
}

end_operation_measurement() {
    local operation_status="$1"
    local ended_at
    local free_kb_after
    local duration_seconds
    local delta_kb
    local metric_prefix
    local tmp_metrics_file
    local tmp_metrics_summary_file

    [ -n "${ACTIVE_OPERATION_STARTED_AT:-}" ] || return 0
    LAST_OPERATION_LOG_FILE="${ACTIVE_OPERATION_LOG_FILE:-}"

    ended_at="$(date +%s)"
    free_kb_after="$(get_free_disk_kb)"
    free_kb_after="${free_kb_after:-0}"
    ACTIVE_OPERATION_FREE_KB_BEFORE="${ACTIVE_OPERATION_FREE_KB_BEFORE:-$free_kb_after}"
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

    if [ "$operation_status" = "success" ]; then
        tmp_metrics_summary_file="$(mktemp)"
        awk -F'\t' -v id="${ACTIVE_OPERATION_ID:-unbekannt}" 'BEGIN {OFS=FS} NR == 1 || $1 != id {print}' "$METRICS_SUMMARY_FILE" > "$tmp_metrics_summary_file" 2>/dev/null || printf 'operation_id\tduration_seconds\tdelta_kb\ttimestamp\n' > "$tmp_metrics_summary_file"
        printf '%s\t%s\t%s\t%s\n' \
            "${ACTIVE_OPERATION_ID:-unbekannt}" \
            "$duration_seconds" \
            "$delta_kb" \
            "$(date '+%Y-%m-%d %H:%M:%S')" >> "$tmp_metrics_summary_file"
        mv "$tmp_metrics_summary_file" "$METRICS_SUMMARY_FILE"
    fi
    invalidate_metric_cache

    ensure_metrics_config
    metric_prefix="LAST_$(operation_id_to_metric_prefix "${ACTIVE_OPERATION_ID:-unknown}")"
    tmp_metrics_file="$(mktemp)"
    grep -Ev "^${metric_prefix}_(TIMESTAMP|STATUS|DURATION_SECONDS|FREE_KB_BEFORE|FREE_KB_AFTER|FREE_GB_BEFORE|FREE_GB_AFTER|DELTA_KB)=" "$METRICS_CONFIG_FILE" > "$tmp_metrics_file" || true
    {
        printf '\n# Letzte Messung fuer %s\n' "${ACTIVE_OPERATION_TITLE:-Unbekannt}"
        printf '%s_TIMESTAMP="%s"\n' "$metric_prefix" "$(date '+%Y-%m-%d %H:%M:%S')"
        printf '%s_STATUS="%s"\n' "$metric_prefix" "$operation_status"
        printf '%s_DURATION_SECONDS="%s"\n' "$metric_prefix" "$duration_seconds"
        printf '%s_FREE_KB_BEFORE="%s"\n' "$metric_prefix" "${ACTIVE_OPERATION_FREE_KB_BEFORE:-0}"
        printf '%s_FREE_KB_AFTER="%s"\n' "$metric_prefix" "${free_kb_after:-0}"
        printf '%s_FREE_GB_BEFORE="%s"\n' "$metric_prefix" "$(( ${ACTIVE_OPERATION_FREE_KB_BEFORE:-0} / 1024 / 1024 ))"
        printf '%s_FREE_GB_AFTER="%s"\n' "$metric_prefix" "$(( ${free_kb_after:-0} / 1024 / 1024 ))"
        printf '%s_DELTA_KB="%s"\n' "$metric_prefix" "$delta_kb"
    } >> "$tmp_metrics_file"
    mv "$tmp_metrics_file" "$METRICS_CONFIG_FILE"

    echo -e "${YELLOW}Messwert gespeichert:${NC} ${ACTIVE_OPERATION_TITLE:-Unbekannt} | Status: $operation_status | Dauer: ${WHITE}$(format_duration_human "$duration_seconds")${NC} | Speicher vorher: $(format_kb_human "${ACTIVE_OPERATION_FREE_KB_BEFORE:-0}") | Speicher nachher: $(format_kb_human "${free_kb_after:-0}") | Speicheränderung: $(format_kb_human "$delta_kb")"
    echo -e "${YELLOW}Messwert in Config aktualisiert:${NC} ${METRICS_CONFIG_FILE}"
    if [ -n "${LAST_OPERATION_LOG_FILE:-}" ]; then
        echo -e "${YELLOW}Installationsprotokoll:${NC} ${LAST_OPERATION_LOG_FILE}"
    fi

    unset ACTIVE_OPERATION_ID ACTIVE_OPERATION_TITLE ACTIVE_OPERATION_STARTED_AT ACTIVE_OPERATION_FREE_KB_BEFORE ACTIVE_OPERATION_LOG_FILE
}

record_menu_load_measurement() {
    local operation_id="$1"
    local operation_title="$2"
    local started_at="$3"
    local free_kb_before="$4"
    local ended_at
    local free_kb_after
    local duration_seconds
    local delta_kb
    local tmp_metrics_summary_file

    [ -n "$started_at" ] || return 0
    ensure_user_workspace
    ensure_metrics_config

    ended_at="$(date +%s)"
    free_kb_after="$(get_free_disk_kb)"
    free_kb_after="${free_kb_after:-0}"
    free_kb_before="${free_kb_before:-$free_kb_after}"
    duration_seconds=$((ended_at - started_at))
    delta_kb=$((free_kb_before - free_kb_after))

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$operation_id" \
        "$operation_title" \
        "success" \
        "$duration_seconds" \
        "$free_kb_before" \
        "$free_kb_after" \
        "$delta_kb" >> "$METRICS_HISTORY_FILE"

    tmp_metrics_summary_file="$(mktemp)"
    awk -F'\t' -v id="$operation_id" 'BEGIN {OFS=FS} NR == 1 || $1 != id {print}' "$METRICS_SUMMARY_FILE" > "$tmp_metrics_summary_file" 2>/dev/null || printf 'operation_id\tduration_seconds\tdelta_kb\ttimestamp\n' > "$tmp_metrics_summary_file"
    printf '%s\t%s\t%s\t%s\n' \
        "$operation_id" \
        "$duration_seconds" \
        "$delta_kb" \
        "$(date '+%Y-%m-%d %H:%M:%S')" >> "$tmp_metrics_summary_file"
    mv "$tmp_metrics_summary_file" "$METRICS_SUMMARY_FILE"
    invalidate_metric_cache
}

show_recent_measurements() {
    ensure_user_workspace
    local white="$WHITE"
    local yellow="$YELLOW"
    local nc="$NC"

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
    tail -n 20 "$METRICS_HISTORY_FILE" | awk -F'\t' -v white="$white" -v yellow="$yellow" -v nc="$nc" '
        NR == 1 && $1 == "timestamp" {
            print
            next
        }
        NF >= 8 {
            duration = $5
            minutes = int(duration / 60)
            seconds = duration % 60
            if (minutes > 0) {
                human = minutes " min " seconds " s"
            } else {
                human = seconds " s"
            }
            print yellow $1 nc " | " $3 " | Status: " $4 " | Dauer: " white human nc " | Speicheränderung: " $8 " KB"
            next
        }
        { print }
    '
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

show_tool_action_plan_intro() {
    local context_label="$1"
    local uninstall_items="$2"
    local install_items="$3"
    local -a uninstall_array=()
    local -a install_array=()
    local uninstall_summary
    local install_summary
    local combined_summary

    read -r -a uninstall_array <<< "$uninstall_items"
    read -r -a install_array <<< "$install_items"
    uninstall_summary="$(summarize_operation_metrics_plain "tool_uninstall" "${uninstall_array[@]}")"
    install_summary="$(summarize_operation_metrics_plain "tool_install" "${install_array[@]}")"
    combined_summary="$(summarize_tool_batch_metrics_plain uninstall_array install_array)"

    clear
    echo
    echo -e "${YELLOW}Willkommen im ${APP_TITLE}.${NC}"
    echo -e "${YELLOW}Es startet jetzt: Tool-Management fuer ${context_label}${NC}"
    echo
    echo -e "${YELLOW}Was passiert:${NC} Das Setup fuehrt ausgewaehlte Tool-Aenderungen in einer sicheren Reihenfolge aus."
    echo -e "${YELLOW}Geplante Reihenfolge:${NC}"
    echo -e "${YELLOW}1. Deinstallationen zuerst:${NC} ${uninstall_items:-${GREEN}(keine)${NC}}"
    echo -e "${YELLOW}2. Installationen danach:${NC} ${install_items:-${GREEN}(keine)${NC}}"
    echo
    echo -e "${YELLOW}Ermittelte Werte:${NC}"
    echo -e "${YELLOW}Deinstallationen gesamt:${NC} ${uninstall_summary}"
    echo -e "${YELLOW}Installationen gesamt:${NC} ${install_summary}"
    echo -e "${YELLOW}Geplante Aenderungen gesamt:${NC} ${combined_summary}"
    echo -e "${YELLOW}Fehlende Werte:${NC} Zeit ${WHITE}--:--:--${NC}, Speicher ${WHITE}--.- MB${NC}"
    echo
    echo -e "${YELLOW}Warum diese Reihenfolge:${NC} So wird Speicherplatz vor neuen Downloads, Builds und Container-Images freigegeben."
    echo -e "${YELLOW}Hinweis:${NC} Bei mehreren Tools erscheinen danach die einzelnen Installationsseiten mit Dauer- und Speicherhinweisen."
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
        "Physik") echo "${PHYSIK_REQUIRED_GB} GB" ;;
        "Chemie") echo "${CHEMIE_REQUIRED_GB} GB" ;;
        "Biologie") echo "${BIOLOGIE_REQUIRED_GB} GB" ;;
        "Bioinformatik") echo "${BIOINFORMATIK_REQUIRED_GB} GB" ;;
        "Molekuelsimulation") echo "${MOLEKUELSIMULATION_REQUIRED_GB} GB" ;;
        "Robotik_Labor") echo "${ROBOTIK_LABOR_REQUIRED_GB} GB" ;;
        "Materialwissenschaft") echo "${MATERIALWISSENSCHAFT_REQUIRED_GB} GB" ;;
        "Mathematik_Simulation") echo "${MATHEMATIK_SIMULATION_REQUIRED_GB} GB" ;;
        "Astronomie_Space_AI") echo "${ASTRONOMIE_SPACE_AI_REQUIRED_GB} GB" ;;
        "Medizinische_Literatur_Recherche") echo "${MEDIZINISCHE_LITERATUR_RECHERCHE_REQUIRED_GB} GB" ;;
        "Umwelt_Klima_Energie") echo "${UMWELT_KLIMA_ENERGIE_REQUIRED_GB} GB" ;;
        "Personal_Assistant_Local_First") echo "${PERSONAL_ASSISTANT_LOCAL_FIRST_REQUIRED_GB} GB" ;;
        "Voice_Command_Center") echo "${VOICE_COMMAND_CENTER_REQUIRED_GB} GB" ;;
        "Knowledge_Librarian") echo "${KNOWLEDGE_LIBRARIAN_REQUIRED_GB} GB" ;;
        "Web_App_Builder") echo "${WEB_APP_BUILDER_REQUIRED_GB} GB" ;;
        "Zero_Trust_Remote_Access") echo "${ZERO_TRUST_REMOTE_ACCESS_REQUIRED_GB} GB" ;;
        "Kubernetes_GPU_Orchestrator") echo "${KUBERNETES_GPU_ORCHESTRATOR_REQUIRED_GB} GB" ;;
        "Storage_NAS_Backup") echo "${STORAGE_NAS_BACKUP_REQUIRED_GB} GB" ;;
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
    local profile_tools_total_summary
    local profile_tool
    local -a profile_tool_array=()
    local operation_id="profile_${operation_kind}_${profile_key}"

    required_gb="$(get_profile_required_gb "$profile_key")"
    extra_notes="Je nach Profil werden mehrere Einzeltools nacheinander installiert oder entfernt. Das kann laenger dauern als bei einem Einzeltool."
    duration_label="$(get_operation_duration_estimate_label "$operation_id" "${SETUP_DOWNLOAD_TIME_ESTIMATE} Download + ${SETUP_INSTALL_TIME_ESTIMATE} Installation/Anpassung je nach Profilgroesse")"
    required_gb="$(get_operation_storage_estimate_label "$operation_id" "$required_gb")"

    for profile_tool in ${PROFILE_CORE_TOOLS[$profile_key]:-} ${PROFILE_EXTENDED_TOOLS[$profile_key]:-} ${PROFILE_INTEGRATION_TOOLS[$profile_key]:-} ${PROFILE_SPECIAL_TOOLS[$profile_key]:-}; do
        [ -n "$profile_tool" ] || continue
        profile_tool_array+=("$profile_tool")
    done
    if [ ${#profile_tool_array[@]} -gt 0 ]; then
        profile_tools_total_summary="$(summarize_operation_metrics_with_missing_plain "tool_install" "${profile_tool_array[@]}")"
        extra_notes="${extra_notes} Ermittelte Summe der zugeordneten Einzeltools: ${profile_tools_total_summary}."
    else
        extra_notes="${extra_notes} Ermittelte Summe der zugeordneten Einzeltools: --:--:-- | --.- MB (fehlend: Zeit 0, Speicher 0), da fuer dieses Profil keine Einzeltool-Liste hinterlegt ist."
    fi

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
    "Freier WSL-/Linux-Dateisystemspeicher jetzt: $(get_free_disk_gb) GB. Primaerquellen sollen aus GitHub kommen; Systemabhaengigkeiten wie apt bleiben als Basis erlaubt."
}

validate_tool_source_policy() {
    local tool_key="$1"
    local action="$2"
    local script_name="${TOOL_SCRIPT_NAMES[$tool_key]}"
    local script_path="$INSTALL_DIR/scripts/tools/${script_name}_${action}.sh"

    load_metrics_config

    [ "$action" = "install" ] || return 0
    [ "${GITHUB_TOOL_SOURCES_PREFERRED:-true}" = "true" ] || return 0
    [ -f "$script_path" ] || return 0

    if grep -Eq 'github\.com|raw\.githubusercontent\.com' "$script_path"; then
        echo -e "${YELLOW}Quellenpruefung:${NC} GitHub-Quelle im Installer erkannt."
        return 0
    fi

    echo -e "${YELLOW}Quellenpruefung:${NC} In ${script_path} wurde keine GitHub-Primaerquelle erkannt."
    echo -e "${YELLOW}Hinweis:${NC} Systemabhaengigkeiten duerfen apt/pip/npm nutzen, aber Primaertools sollen aus GitHub-Repos kommen."

    if [ "${STRICT_GITHUB_TOOL_SOURCES:-false}" = "true" ] && [ "${ALLOW_NON_GITHUB_TOOL_SOURCE:-false}" != "true" ]; then
        echo -e "${RED}Abbruch: STRICT_GITHUB_TOOL_SOURCES=true blockiert diesen Installer ohne erkannte GitHub-Quelle.${NC}"
        echo -e "${YELLOW}Bewusste Ausnahme: ALLOW_NON_GITHUB_TOOL_SOURCE=1 setzen oder den Installer auf GitHub-Quelle umbauen.${NC}"
        return 1
    fi

    return 0
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
    operation_slug="$(printf '%s' "${ACTIVE_OPERATION_ID:-$(basename "$script_path" .sh)}" | tr -cs '[:alnum:]_.-' '_')"
    timestamp_slug="$(date +%Y%m%d_%H%M%S)"
    ACTIVE_OPERATION_LOG_FILE="$USER_INSTALL_LOG_DIR/${timestamp_slug}_${operation_slug}.log"
    mkdir -p "$USER_INSTALL_LOG_DIR"

    if is_preference_enabled "${INSTALL_MONITORING_VERBOSE:-false}" || is_preference_enabled "${INSTALL_MONITORING_MANUAL_FLOW:-false}"; then
        echo -e "${YELLOW}Erweiterte Installationsüberwachung ist aktiv.${NC}"
        echo -e "${YELLOW}Logdatei:${NC} ${ACTIVE_OPERATION_LOG_FILE}"
    else
        echo -e "${YELLOW}Installationsprotokoll:${NC} ${ACTIVE_OPERATION_LOG_FILE}"
    fi
    bash "$script_path" "$@" 2>&1 | tee "$ACTIVE_OPERATION_LOG_FILE"
    script_rc=${PIPESTATUS[0]}

    reset_terminal_display
    return $script_rc
}

run_setup_log_cleanup() {
    local mode="${1:-dry-run}"
    local failed_only="${2:-false}"
    local cleanup_script="$INSTALL_DIR/scripts/cleanup_setup_logs.sh"
    local cleanup_args=("--dry-run")

    ensure_user_workspace

    if [ "$mode" = "apply" ]; then
        cleanup_args=("--apply")
    fi

    if [ "$failed_only" = "true" ]; then
        cleanup_args+=("--failed-only")
    fi

    if [ ! -f "$cleanup_script" ]; then
        echo -e "${YELLOW}Log-Aufräumskript nicht gefunden: $cleanup_script${NC}"
        return 1
    fi

    bash "$cleanup_script" "${cleanup_args[@]}" \
        --days "${LOG_CLEANUP_RETENTION_DAYS:-14}" \
        --keep "${LOG_CLEANUP_KEEP_RECENT:-30}"
}

maybe_cleanup_logs_before_operation() {
    if ! is_preference_enabled "${LOG_CLEANUP_BEFORE_OPERATION:-false}"; then
        return 0
    fi

    echo -e "${YELLOW}Log-Aufräumung vor dem nächsten Installations-/Deinstallationslauf ist aktiv.${NC}"
    run_setup_log_cleanup "apply" || echo -e "${YELLOW}Hinweis: Log-Aufräumung konnte nicht vollständig ausgeführt werden. Installation läuft weiter.${NC}"
}

show_installation_monitoring_menu() {
    local monitoring_state
    local cleanup_state
    local overview_metrics_state
    local loading_notice_state
    local monitoring_mark
    local cleanup_mark
    local overview_metrics_mark
    local loading_notice_mark
    local separator_line="${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}"

    while true; do
        if is_preference_enabled "${INSTALL_MONITORING_VERBOSE:-false}"; then
            monitoring_state="aktiv"
            monitoring_mark="(*)"
        else
            monitoring_state="inaktiv"
            monitoring_mark="( )"
        fi

        if is_preference_enabled "${LOG_CLEANUP_BEFORE_OPERATION:-false}"; then
            cleanup_state="aktiv"
            cleanup_mark="(*)"
        else
            cleanup_state="inaktiv"
            cleanup_mark="( )"
        fi
        if is_preference_enabled "${OVERVIEW_METRICS_ENABLED:-true}"; then
            overview_metrics_state="aktiv"
            overview_metrics_mark="(*)"
        else
            overview_metrics_state="inaktiv"
            overview_metrics_mark="( )"
        fi
        if is_preference_enabled "${MENU_LOADING_NOTICE_ENABLED:-true}"; then
            loading_notice_state="aktiv"
            loading_notice_mark="(*)"
        else
            loading_notice_state="inaktiv"
            loading_notice_mark="( )"
        fi

        dialog --clear --backtitle "$APP_TITLE" \
        --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
        --title "INSTALLATIONSÜBERWACHUNG" --menu "Zusätzliche Überwachung, Logansicht und sichere Log-Aufräumung." 42 112 22 \
        "1" "${monitoring_mark} Erweiterte Installationsüberwachung umschalten (aktuell: ${monitoring_state})" \
        "────────" "$separator_line" \
        "2" "${overview_metrics_mark} Zeit-/Speicherwerte in Tool-/Profilübersichten umschalten (aktuell: ${overview_metrics_state})" \
        "3" "${loading_notice_mark} Lade-Hinweis vor Tool-/Profilübersichten umschalten (aktuell: ${loading_notice_state})" \
        "─────────" "$separator_line" \
        "4" "Log-Verzeichnis anzeigen" \
        "5" "Letzte Installations-Logs anzeigen" \
        "6" "Letzte Messwerte anzeigen" \
        "──────────" "$separator_line" \
        "7" "${cleanup_mark} Log-Aufräumung vor Installationen umschalten (aktuell: ${cleanup_state})" \
        "8" "Log-Aufräumung Trockenlauf anzeigen" \
        "9" "Alte Logs jetzt löschen" \
        "10" "Alte Fehler-Logs jetzt löschen" \
        "11" "Aufbewahrung einstellen (Tage/neueste Dateien)" \
        "───────────" "$separator_line" \
        "12" "Installationslauf-Diagnose erstellen" \
        "13" "Abhängigkeiten-/Speicher-Snapshot erstellen" \
        "────────────" "$separator_line" \
        "14" "Installationsreste/Caches Trockenlauf anzeigen" \
        "15" "Installationsreste/Caches bereinigen (mit Sicherheitsabfrage)" \
        "─────────────" "$separator_line" \
        "16" "/opt-Toolreste Trockenlauf anzeigen" \
        "17" "/opt-Toolreste bereinigen (jedes Verzeichnis Ja/Nein)" \
        "──────────────" "$separator_line" \
        "18" "${TXT_BACK_ITEM:-Zurück}" 2> /tmp/install_monitoring_choice

        if [ $? -ne 0 ]; then
            return 0
        fi

        case "$(cat /tmp/install_monitoring_choice)" in
            ────────*)
                continue
                ;;
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
                if is_preference_enabled "${OVERVIEW_METRICS_ENABLED:-true}"; then
                    set_overview_metrics_mode "false"
                    echo -e "${GREEN}Zeit-/Speicherwerte in Tool-/Profilübersichten wurden deaktiviert.${NC}"
                else
                    set_overview_metrics_mode "true"
                    echo -e "${GREEN}Zeit-/Speicherwerte in Tool-/Profilübersichten wurden aktiviert.${NC}"
                fi
                read -p "Drücken Sie Enter..."
                ;;
            3)
                if is_preference_enabled "${MENU_LOADING_NOTICE_ENABLED:-true}"; then
                    set_menu_loading_notice_mode "false"
                    echo -e "${GREEN}Lade-Hinweis vor Tool-/Profilübersichten wurde deaktiviert.${NC}"
                else
                    set_menu_loading_notice_mode "true"
                    echo -e "${GREEN}Lade-Hinweis vor Tool-/Profilübersichten wurde aktiviert.${NC}"
                fi
                read -p "Drücken Sie Enter..."
                ;;
            4)
                clear
                echo
                echo -e "${YELLOW}Log-Verzeichnis für Installations- und Deinstallationsläufe:${NC}"
                echo "$USER_INSTALL_LOG_DIR"
                echo
                read -p "Drücken Sie Enter..."
                ;;
            5)
                show_recent_install_logs
                ;;
            6)
                show_recent_measurements
                ;;
            7)
                if is_preference_enabled "${LOG_CLEANUP_BEFORE_OPERATION:-false}"; then
                    set_log_cleanup_mode "false"
                    echo -e "${GREEN}Automatische Log-Aufräumung vor Installationen wurde deaktiviert.${NC}"
                else
                    set_log_cleanup_mode "true"
                    echo -e "${GREEN}Automatische Log-Aufräumung vor Installationen wurde aktiviert.${NC}"
                    echo -e "${YELLOW}Es werden nur alte Installations- und Diagnoseberichte im Benutzer-Workspace rotiert.${NC}"
                fi
                read -p "Drücken Sie Enter..."
                ;;
            8)
                clear
                run_setup_log_cleanup "dry-run"
                echo
                read -p "Drücken Sie Enter..."
                ;;
            9)
                clear
                echo -e "${YELLOW}Alte Logs werden jetzt anhand der aktuellen Aufbewahrungsregeln gelöscht.${NC}"
                run_setup_log_cleanup "apply"
                echo
                read -p "Drücken Sie Enter..."
                ;;
            10)
                clear
                echo -e "${YELLOW}Alte Fehler-Logs werden jetzt anhand der aktuellen Aufbewahrungsregeln gelöscht.${NC}"
                run_setup_log_cleanup "apply" "true"
                echo
                read -p "Drücken Sie Enter..."
                ;;
            11)
                show_log_cleanup_settings_menu
                ;;
            12)
                clear
                bash "$INSTALL_DIR/scripts/install_run_diagnostics.sh"
                echo
                read -p "Installationslauf-Diagnose abgeschlossen. Drücken Sie Enter..."
                ;;
            13)
                clear
                bash "$INSTALL_DIR/scripts/dependency_snapshot.sh"
                echo
                read -p "Abhängigkeiten-/Speicher-Snapshot abgeschlossen. Drücken Sie Enter..."
                ;;
            14)
                clear
                bash "$INSTALL_DIR/scripts/cleanup_installation_residues.sh" --dry-run --all
                echo
                read -p "Trockenlauf abgeschlossen. Drücken Sie Enter..."
                ;;
            15)
                clear
                bash "$INSTALL_DIR/scripts/cleanup_installation_residues.sh" --apply --all
                echo
                read -p "Bereinigung abgeschlossen oder abgebrochen. Drücken Sie Enter..."
                ;;
            16)
                clear
                bash "$INSTALL_DIR/scripts/cleanup_installation_residues.sh" --dry-run --opt-tools
                echo
                read -p "Trockenlauf abgeschlossen. Drücken Sie Enter..."
                ;;
            17)
                clear
                echo -e "${YELLOW}/opt-Toolreste werden jetzt einzeln abgefragt. Docker-Volumes bleiben geschützt.${NC}"
                bash "$INSTALL_DIR/scripts/cleanup_installation_residues.sh" --apply --opt-tools
                echo
                read -p "Bereinigung abgeschlossen oder abgebrochen. Drücken Sie Enter..."
                ;;
            18)
                return 0
                ;;
        esac
    done
}

show_log_cleanup_settings_menu() {
    local new_days
    local new_keep

    dialog --clear --backtitle "$APP_TITLE" \
    --title "LOG-AUFBEWAHRUNG" --inputbox "Wie viele Tage sollen Installations-/Diagnoselogs mindestens behalten werden?" 10 90 "${LOG_CLEANUP_RETENTION_DAYS:-14}" 2> /tmp/log_cleanup_days

    if [ $? -ne 0 ]; then
        return 0
    fi

    new_days="$(cat /tmp/log_cleanup_days)"
    if ! set_log_cleanup_number_preference "LOG_CLEANUP_RETENTION_DAYS" "$new_days"; then
        read -p "Drücken Sie Enter..."
        return 1
    fi

    dialog --clear --backtitle "$APP_TITLE" \
    --title "LOG-AUFBEWAHRUNG" --inputbox "Wie viele neueste Dateien sollen pro Log-Ordner immer behalten werden?" 10 90 "${LOG_CLEANUP_KEEP_RECENT:-30}" 2> /tmp/log_cleanup_keep

    if [ $? -ne 0 ]; then
        return 0
    fi

    new_keep="$(cat /tmp/log_cleanup_keep)"
    if ! set_log_cleanup_number_preference "LOG_CLEANUP_KEEP_RECENT" "$new_keep"; then
        read -p "Drücken Sie Enter..."
        return 1
    fi

    echo -e "${GREEN}Log-Aufbewahrung aktualisiert: ${LOG_CLEANUP_RETENTION_DAYS} Tage, neueste ${LOG_CLEANUP_KEEP_RECENT} Dateien behalten.${NC}"
    read -p "Drücken Sie Enter..."
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
    --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
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

find_latest_install_log_file() {
    ensure_user_workspace
    find "$USER_INSTALL_LOG_DIR" -maxdepth 1 -type f -name '*.log' -printf '%T@ %p\n' 2>/dev/null |
        sort -nr |
        awk 'NR == 1 {sub(/^[^ ]+ /, ""); print}'
}

resolve_install_log_file() {
    local current_log_file="${1:-}"

    if [ -n "$current_log_file" ] && [ -f "$current_log_file" ]; then
        printf '%s\n' "$current_log_file"
        return 0
    fi

    find_latest_install_log_file
}

show_install_log_tail_now() {
    local current_log_file="${1:-}"
    local log_file

    log_file="$(resolve_install_log_file "$current_log_file")"
    if [ -z "$log_file" ] || [ ! -f "$log_file" ]; then
        echo -e "${YELLOW}Kein Installationsprotokoll gefunden.${NC}"
        return 1
    fi

    clear
    echo
    echo -e "${YELLOW}Installationsprotokoll:${NC} $log_file"
    echo
    tail -n 220 "$log_file"
    echo
    read -p "Drücken Sie Enter..."
}

run_install_log_diagnostics_now() {
    local current_log_file="${1:-}"
    local email_mode="${2:-no-email}"
    local log_file
    local diagnostics_script="$INSTALL_DIR/scripts/tool_log_diagnostics.sh"

    log_file="$(resolve_install_log_file "$current_log_file")"
    if [ -z "$log_file" ] || [ ! -f "$log_file" ]; then
        echo -e "${YELLOW}Kein Installationsprotokoll gefunden.${NC}"
        return 1
    fi

    if [ ! -f "$diagnostics_script" ]; then
        echo -e "${RED}Fehler: Tool-Logdiagnose nicht gefunden: $diagnostics_script${NC}"
        return 1
    fi

    clear
    if [ "$email_mode" = "email" ]; then
        bash "$diagnostics_script" --log "$log_file" --email-now
    else
        bash "$diagnostics_script" --log "$log_file" --no-email
    fi
    echo
    read -p "Drücken Sie Enter..."
}

show_diagnostics_quick_menu() {
    while true; do
        dialog --clear --backtitle "$APP_TITLE" \
        --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
        --title "TOOL-DIAGNOSE & LETZTE FEHLER" \
        --menu "Schneller Zugriff auf die letzten Installationsprotokolle und Diagnoseberichte." 22 104 6 \
        "1" "Letzten fehlgeschlagenen Fehlerbericht anzeigen" \
        "2" "Letztes Installationsprotokoll anzeigen" \
        "3" "Tool-Logdiagnose interaktiv starten" \
        "4" "Installationslauf-Diagnose erstellen" \
        "5" "Abhaengigkeiten-/Speicher-Snapshot erstellen" \
        "6" "Letztes Installationsprotokoll per E-Mail senden" 2> /tmp/diagnostics_quick_choice

        if [ $? -ne 0 ]; then
            clear
            return 0
        fi

        case "$(cat /tmp/diagnostics_quick_choice)" in
            1)
                bash "$INSTALL_DIR/scripts/last_install_log.sh" --failed
                read -p "Letzter Fehlerbericht angezeigt. Drücken Sie Enter..."
                ;;
            2)
                bash "$INSTALL_DIR/scripts/last_install_log.sh"
                read -p "Letztes Installationsprotokoll angezeigt. Drücken Sie Enter..."
                ;;
            3)
                bash "$INSTALL_DIR/scripts/tool_log_diagnostics.sh"
                read -p "Tool-Logdiagnose abgeschlossen. Drücken Sie Enter..."
                ;;
            4)
                bash "$INSTALL_DIR/scripts/install_run_diagnostics.sh"
                read -p "Installationslauf-Diagnose abgeschlossen. Drücken Sie Enter..."
                ;;
            5)
                bash "$INSTALL_DIR/scripts/dependency_snapshot.sh"
                read -p "Abhängigkeiten-/Speicher-Snapshot abgeschlossen. Drücken Sie Enter..."
                ;;
            6)
                bash "$INSTALL_DIR/scripts/last_install_log.sh" --email
                read -p "E-Mail-Diagnose abgeschlossen. Drücken Sie Enter..."
                ;;
        esac
    done
}

handle_manual_tool_post_action() {
    local tool_key="$1"
    local action_label="$2"
    local operation_status="${3:-success}"
    local upcoming_preview="${4:-}"
    local current_log_file="${LAST_OPERATION_LOG_FILE:-}"
    local next_choice
    local prompt_text
    local default_choice="N"

    if ! is_preference_enabled "${INSTALL_MONITORING_MANUAL_FLOW:-false}" && [ "$operation_status" != "failed" ]; then
        return 0
    fi

    if [ "$operation_status" = "failed" ]; then
        default_choice="Z"
    fi

    echo
    if [ "$operation_status" = "failed" ]; then
        echo -e "${RED}Fehler erkannt bei '${action_label} ${tool_key}'.${NC}"
        echo -e "${YELLOW}Bevor der Batch weiterläuft, kannst du sofort Log, Diagnose oder E-Mail-Diagnose öffnen.${NC}"
    else
        echo -e "${YELLOW}Erweiterte Installationsüberwachung ist aktiv.${NC}"
        echo -e "${YELLOW}Nach dem Schritt '${action_label} ${tool_key}' wird nicht automatisch weitergesprungen.${NC}"
    fi
    if [ -n "$current_log_file" ]; then
        echo -e "${YELLOW}Logdatei:${NC} $current_log_file"
    fi
    if [ -n "$upcoming_preview" ]; then
        echo -e "${YELLOW}Als Nächstes geplant:${NC} $upcoming_preview"
    else
        echo -e "${YELLOW}Als Nächstes geplant:${NC} (keine weiteren Tools in diesem Batch)"
    fi

    while true; do
        if [ "$operation_status" = "failed" ]; then
            prompt_text="Zurück ins Setup [Z], weiter/nächstes Tool [N], Log [L], Diagnose [D] oder Diagnose per E-Mail [E]? "
        else
            prompt_text="Weiter/nächstes Tool [N], zurück ins Setup [Z], Log anzeigen [L], Diagnose [D] oder Diagnose per E-Mail [E]? "
        fi
        read -r -p "$prompt_text" next_choice
        case "$(printf '%s' "${next_choice:-$default_choice}" | tr '[:lower:]' '[:upper:]')" in
            N|"")
                TOOL_BATCH_ABORT_REQUESTED=0
                break
                ;;
            Z)
                TOOL_BATCH_ABORT_REQUESTED=1
                break
                ;;
            L)
                show_install_log_tail_now "$current_log_file"
                ;;
            D)
                run_install_log_diagnostics_now "$current_log_file" "no-email"
                ;;
            E)
                run_install_log_diagnostics_now "$current_log_file" "email"
                ;;
            *)
                echo -e "${YELLOW}Bitte nur: N, Z, L, D oder E eingeben.${NC}"
                ;;
        esac
    done

    LAST_OPERATION_LOG_FILE=""
}

format_tool_queue_preview() {
    local max_items="${1:-6}"
    shift || true
    local item
    local count=0
    local preview=""
    local remaining=0

    for item in "$@"; do
        [ -n "$item" ] || continue
        if [ "$count" -lt "$max_items" ]; then
            if [ -n "$preview" ]; then
                preview="${preview}, ${item}"
            else
                preview="$item"
            fi
        else
            remaining=$((remaining + 1))
        fi
        count=$((count + 1))
    done

    if [ "$count" -eq 0 ]; then
        printf '%s' ""
    elif [ "$remaining" -gt 0 ]; then
        printf '%s (+%s weitere)' "$preview" "$remaining"
    else
        printf '%s' "$preview"
    fi
}

show_management_loading_notice() {
    local target_label="$1"
    local detail_text="$2"

    load_setup_language
    if ! is_preference_enabled "${MENU_LOADING_NOTICE_ENABLED:-true}"; then
        return 0
    fi

    if ! dialog --clear --backtitle "$APP_TITLE" \
        --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
        --title "ANSICHT WIRD VORBEREITET" \
        --yesno "Die Ansicht '${target_label}' wird jetzt vorbereitet.\n\n${detail_text}\n\nDas Laden kann je nach WSL-/Datentraegerzustand einige Sekunden bis mehrere Minuten dauern. Wenn Zeit- und Speicherwerte aktiv sind, werden Messwerte aus der lokalen Summary-Datei gelesen.\n\nFortfahren?" 15 92; then
        return 1
    fi

    (
        for percent in 0 20 45 70 90 100; do
            echo "$percent"
            sleep 0.05
        done
    ) | dialog --clear --backtitle "$APP_TITLE" \
        --title "LADE ${target_label}" \
        --gauge "Bereite Menueeintraege, Status und optionale Messwerte vor..." 8 78 0

    reset_terminal_display
    return 0
}

confirm_tool_batch_step() {
    local action_label="$1"
    local tool_key="$2"
    local upcoming_preview="$3"
    local step_choice

    if ! is_preference_enabled "${INSTALL_MONITORING_MANUAL_FLOW:-false}"; then
        return 0
    fi

    echo
    echo -e "${YELLOW}Naechster Batch-Schritt:${NC} ${action_label} ${tool_key}"
    if [ -n "$upcoming_preview" ]; then
        echo -e "${YELLOW}Danach geplant:${NC} $upcoming_preview"
    else
        echo -e "${YELLOW}Danach geplant:${NC} (keine weiteren Tools in diesem Batch)"
    fi

    while true; do
        read -r -p "Ausfuehren [N], dieses Tool ueberspringen [S] oder Batch abbrechen [Z]? " step_choice
        case "$(printf '%s' "${step_choice:-N}" | tr '[:lower:]' '[:upper:]')" in
            N|"")
                return 0
                ;;
            S)
                echo -e "${YELLOW}${action_label} ${tool_key} wurde uebersprungen.${NC}"
                return 2
                ;;
            Z)
                TOOL_BATCH_ABORT_REQUESTED=1
                return 1
                ;;
            *)
                echo -e "${YELLOW}Bitte nur: N, S oder Z eingeben.${NC}"
                ;;
        esac
    done
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
        read -r -p "Zurück ins Profilmenü [N], direkt zurück ins Setup [Z], Log anzeigen [L], Diagnose [D] oder Diagnose per E-Mail [E]? " next_choice
        case "$(printf '%s' "${next_choice:-N}" | tr '[:lower:]' '[:upper:]')" in
            N|"")
                PROFILE_FLOW_ABORT_REQUESTED=0
                break
                ;;
            Z)
                PROFILE_FLOW_ABORT_REQUESTED=1
                break
                ;;
            L)
                show_install_log_tail_now "$current_log_file"
                ;;
            D)
                run_install_log_diagnostics_now "$current_log_file" "no-email"
                ;;
            E)
                run_install_log_diagnostics_now "$current_log_file" "email"
                ;;
            *)
                echo -e "${YELLOW}Bitte nur: N, Z, L, D oder E eingeben.${NC}"
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
        --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
        --title "${TXT_WORKSPACE_MENU_TITLE:-BENUTZER-WORKSPACE}" --menu "${TXT_WORKSPACE_MENU_PROMPT:-Bearbeitbare und sensible Dateien liegen außerhalb des Repos.}" 22 104 9 \
        "1" "${TXT_WORKSPACE_OPTION_1:-Pfad anzeigen}" \
        "2" "${TXT_WORKSPACE_OPTION_2:-Workspace-Dateien auflisten}" \
        "3" "${TXT_WORKSPACE_OPTION_3:-OpenClaw Vorlagen aus dem Repo neu in den Workspace kopieren}" \
        "4" "${TXT_WORKSPACE_OPTION_4:-Profil-Quellen und Profilseiten aus dem Repo neu in den Workspace kopieren}" \
        "5" "${TXT_WORKSPACE_OPTION_5:-Prompt-Bereich im Workspace anzeigen}" \
        "6" "${TXT_WORKSPACE_OPTION_6:-Letzte Messwerte anzeigen}" \
        "7" "${TXT_WORKSPACE_OPTION_7:-Benutzer-Workspace komplett löschen}" \
        "8" "${TXT_WORKSPACE_OPTION_8:-Sprache ändern}" \
        "9" "${TXT_WORKSPACE_OPTION_9:-${TXT_BACK_ITEM:-Zurück}}" 2> /tmp/user_workspace_choice

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
                dialog --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" --yesno "${TXT_WORKSPACE_DELETE_CONFIRM:-Der gesamte Benutzer-Workspace wird gelöscht. Darin können .env-Vorlagen, Statusdateien und weitere sensible Daten liegen. Wirklich fortfahren?}" 10 100
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
        --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
        --title "${TXT_OPTIONS_MENU_TITLE:-OPTIONEN}" --menu "${TXT_OPTIONS_MENU_PROMPT:-Wählen Sie eine Verwaltungs- oder Konfigurationsfunktion:}" 40 110 24 \
        "1" "${TXT_OPTIONS_1:-Sprache ändern}" \
        "2" "${TXT_OPTIONS_14:-Sprachpakete verwalten}" \
        "────────" "────────────── Sprache / Basis ──────────────" \
        "3" "${TXT_OPTIONS_2:-Setup-Messwerte & Benchmarks bearbeiten}" \
        "─────────" "────────── Messwerte / Workspace ────────────" \
        "4" "${TXT_OPTIONS_7:-Benutzer-Workspace verwalten}" \
        "5" "${TXT_OPTIONS_5:-Ollama Modellkatalog}" \
        "6" "${TXT_OPTIONS_3:-Ollama Modelfile-Assistent}" \
        "7" "${TXT_OPTIONS_4:-LLM-Builder Projektstruktur-Assistent}" \
        "8" "${TXT_OPTIONS_8:-Custom GitHub-Quellen & Ollama-Builds}" \
        "──────────" "───────── Quellen / Konfiguration ───────────" \
        "9" "${TXT_OPTIONS_9:-LLMOps Plattform Konfiguration (.env Stack)}" \
        "10" "${TXT_OPTIONS_10:-Huginn Konfiguration (.env Vorlage)}" \
        "───────────" "──────────── Setup / Diagnose ───────────────" \
        "11" "${TXT_OPTIONS_6:-Setup-Repository hart reparieren / auf GitHub main zurücksetzen}" \
        "12" "${TXT_OPTIONS_12:-Nur auf Setup-Updates prüfen}" \
        "13" "${TXT_OPTIONS_13:-Jetzt nur das Setup aktualisieren}" \
        "────────────" "──────── Installation / Diagnose ────────────" \
        "14" "${TXT_OPTIONS_11:-Installationsüberwachung konfigurieren}" \
        "15" "${TXT_OPTIONS_15:-Tooldiagnose / letzter Fehlerbericht}" \
        "16" "E-Mail-Diagnose konfigurieren / Testmail senden" \
        "17" "Installationslauf-Diagnose erstellen" \
        "18" "Abhängigkeiten-/Speicher-Snapshot erstellen" 2> /tmp/options_choice

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
                run_bash_script "$INSTALL_DIR/scripts/language_pack_manager.sh"
                ;;
            3)
                show_metrics_editor
                read -p "Setup-Messwerte aktualisiert. Drücken Sie Enter..."
                ;;
            4)
                show_user_workspace_menu
                ;;
            5)
                run_bash_script "$INSTALL_DIR/scripts/ollama_model_catalog_manager.sh"
                ;;
            6)
                run_bash_script "$INSTALL_DIR/scripts/ollama_modelfile_assistant.sh"
                ;;
            7)
                run_bash_script "$INSTALL_DIR/scripts/llm_builder_project_scaffold.sh"
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
                show_operation_intro \
                "Harter Setup-Abgleich mit GitHub main" \
                "Das Setup-Repository wird zwangsweise auf origin/main zurückgesetzt. Lokale Änderungen im Setup-Verzeichnis gehen dabei verloren." \
                "Meist nur wenige Minuten, abhängig von Netzwerk und Repo-Größe" \
                "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB" \
                "Nutze diese Methode nur, wenn das normale Update nicht greift oder ein alter Setup-Stand festhaengt."
                run_bash_script "$INSTALL_DIR/scripts/auto_update_hard.sh"
                read -p "Harter Setup-Abgleich abgeschlossen. Drücken Sie Enter, um das Setup-Menue neu zu starten..."
                restart_setup_menu_after_update
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
                local_update_rc=0
                show_operation_intro \
                "Jetzt nur das Setup aktualisieren" \
                "Aktualisiert nur dieses Setup-Repository gegen origin/main. Betriebssystem und pnpm bleiben dabei unberuehrt." \
                "Wenige Sekunden bis einige Minuten, je nach Netzwerk und Git-Stand" \
                "$(get_operation_storage_estimate_label "main_menu_setup_only_update" "${MIN_FREE_GB_ABSOLUTE}-${MIN_FREE_GB_RECOMMENDED} GB")" \
                "Bei lokalen Aenderungen im Setup wird das Repo-Update bewusst uebersprungen, damit nichts ueberschrieben wird."
                begin_operation_measurement "main_menu_setup_only_update" "Nur das Setup aktualisieren"
                run_bash_script "$INSTALL_DIR/scripts/update_setup_only.sh"
                local_update_rc=$?
                if [ "$local_update_rc" -eq 0 ]; then
                    end_operation_measurement "success"
                elif [ "$local_update_rc" -eq 2 ]; then
                    end_operation_measurement "skipped"
                else
                    end_operation_measurement "failed"
                fi
                if [ "$local_update_rc" -eq 0 ]; then
                    read -p "Setup-Update abgeschlossen. Drücken Sie Enter, um das Setup-Menue neu zu starten..."
                    restart_setup_menu_after_update
                fi
                read -p "Setup-Update abgeschlossen. Drücken Sie Enter..."
                ;;
            14)
                show_installation_monitoring_menu
                ;;
            15)
                show_diagnostics_quick_menu
                ;;
            16)
                run_bash_script "$INSTALL_DIR/scripts/mail_config_manager.sh"
                ;;
            17)
                bash "$INSTALL_DIR/scripts/install_run_diagnostics.sh"
                read -p "Installationslauf-Diagnose abgeschlossen. Drücken Sie Enter..."
                ;;
            18)
                bash "$INSTALL_DIR/scripts/dependency_snapshot.sh"
                read -p "Abhängigkeiten-/Speicher-Snapshot abgeschlossen. Drücken Sie Enter..."
                ;;
            ────────*)
                continue
                ;;
        esac
    done
}

restart_setup_menu_after_update() {
    echo
    echo -e "${YELLOW}Das Setup-Menue wird jetzt neu gestartet, damit keine alte geladene Bash-Version weiterlaeuft.${NC}"
    echo -e "${YELLOW}Falls du danach alte Inhalte siehst, pruefe bitte, ob noch ein zweites Setup-Terminal offen ist.${NC}"
    sleep 2
    exec bash "$INSTALL_DIR/setup_ultimate.sh"
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

run_ordered_tool_actions() {
    local context_label="$1"
    local -n uninstall_queue_ref="$2"
    local -n install_queue_ref="$3"
    local tool_key
    local step_rc
    local upcoming_preview
    local -a remaining_tools=()
    local index

    if [ "${#uninstall_queue_ref[@]}" -eq 0 ] && [ "${#install_queue_ref[@]}" -eq 0 ]; then
        echo -e "${YELLOW}Keine Tool-Aenderungen fuer ${context_label} ausgewaehlt.${NC}"
        return 0
    fi

    show_tool_action_plan_intro \
        "$context_label" \
        "${uninstall_queue_ref[*]}" \
        "${install_queue_ref[*]}"

    for index in "${!uninstall_queue_ref[@]}"; do
        tool_key="${uninstall_queue_ref[$index]}"
        [ -n "$tool_key" ] || continue
        remaining_tools=("${uninstall_queue_ref[@]:$((index + 1))}" "${install_queue_ref[@]}")
        upcoming_preview="$(format_tool_queue_preview 6 "${remaining_tools[@]}")"
        confirm_tool_batch_step "Deinstallation" "$tool_key" "$upcoming_preview"
        step_rc=$?
        if [ "$step_rc" -eq 2 ]; then
            continue
        elif [ "$step_rc" -ne 0 ]; then
            echo -e "${YELLOW}Batch wurde vor '${tool_key}' abgebrochen. Rueckkehr ins Setup.${NC}"
            return 1
        fi
        TOOL_BATCH_UPCOMING_PREVIEW="$upcoming_preview"
        uninstall_tool "$tool_key"
        TOOL_BATCH_UPCOMING_PREVIEW=""
        if [ "${TOOL_BATCH_ABORT_REQUESTED:-0}" = "1" ]; then
            echo -e "${YELLOW}Batch wurde auf Wunsch nach '${tool_key}' abgebrochen. Rueckkehr ins Setup.${NC}"
            return 1
        fi
    done

    for index in "${!install_queue_ref[@]}"; do
        tool_key="${install_queue_ref[$index]}"
        [ -n "$tool_key" ] || continue
        remaining_tools=("${install_queue_ref[@]:$((index + 1))}")
        upcoming_preview="$(format_tool_queue_preview 6 "${remaining_tools[@]}")"
        confirm_tool_batch_step "Installation" "$tool_key" "$upcoming_preview"
        step_rc=$?
        if [ "$step_rc" -eq 2 ]; then
            continue
        elif [ "$step_rc" -ne 0 ]; then
            echo -e "${YELLOW}Batch wurde vor '${tool_key}' abgebrochen. Rueckkehr ins Setup.${NC}"
            return 1
        fi
        TOOL_BATCH_UPCOMING_PREVIEW="$upcoming_preview"
        install_tool "$tool_key"
        TOOL_BATCH_UPCOMING_PREVIEW=""
        if [ "${TOOL_BATCH_ABORT_REQUESTED:-0}" = "1" ]; then
            echo -e "${YELLOW}Batch wurde auf Wunsch nach '${tool_key}' abgebrochen. Rueckkehr ins Setup.${NC}"
            return 1
        fi
    done

    return 0
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
    local tool_key
    local install_path

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

    # Reparatur fuer Tools, die real unter /opt vorhanden sind, aber durch
    # alte Installer/abgebrochene Menues noch nicht im Statusfile stehen. Ohne
    # diese Nachsynchronisierung kann ein Abwaehlen im Tool-Menue keine
    # Deinstallation planen, weil das Setup das Tool nicht als installiert kennt.
    while IFS='|' read -r tool_key install_path; do
        [ -n "$tool_key" ] || continue
        [ -n "$install_path" ] || continue
        if [ -e "$install_path" ] && ! grep -Fxq "$tool_key" "$TOOL_STATUS_FILE" 2>/dev/null; then
            append_unique_line "$TOOL_STATUS_FILE" "$tool_key"
            status_changed=1
        fi
    done <<'EOF'
AutoGPT|/opt/autogpt/autogpt_platform
Airbyte|/opt/airbyte
Clawhub|/opt/clawhub
ComfyUI|/opt/comfyui
Continue_Dev|/opt/continue_dev
OpenManus|/opt/openmanus
Activepieces|/opt/activepieces
Apache_Tika|/opt/apache_tika
EOF

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
PROFILE_KEYS=("Programmierer" "Repo_Maintainer" "Repo_Maintainer_Agent" "Agent_Orchestrator" "LLM_Builder" "Research_Agent" "KI_Forschung" "Physik" "Chemie" "Biologie" "Bioinformatik" "Molekuelsimulation" "Robotik_Labor" "Materialwissenschaft" "Mathematik_Simulation" "Astronomie_Space_AI" "Medizinische_Literatur_Recherche" "Umwelt_Klima_Energie" "Data_Engineering" "Document_AI" "Knowledge_Librarian" "Memory_Import_Export" "Personal_Knowledge_OS" "Personal_Assistant_Local_First" "Next_Level_Persona_System" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht" "DevOps_SRE" "Security_Analyst" "Ethical_HackerGPT" "Compliance_Privacy" "Zero_Trust_Remote_Access" "Audio" "Voice_Assistant" "Voice_Command_Center" "Jarvis_FritzBox_Alexa_Home_Assistant" "Media_Musik" "Content_Automation" "Image_Generation" "Video_Generation" "Video_Generation_ComfyUI_Wan" "GameDev_3D_Studio_NEXTLEVEL" "OpenHiggsStack_AI_Cinema_Studio" "Visual_Creator" "Web_App_Builder" "Kubernetes_GPU_Orchestrator" "Storage_NAS_Backup" "Trading_AI" "Web3_Crypto_Tools")
PROFILES["Programmierer"]="Tools für Entwicklung, Code-Generierung (DeepSeek Coder), Git-Integration, Huginn, Clawhub CLI. Ideal für Entwickler und Automatisierungsexperten."
PROFILES["Media_Musik"]="Tools für Audio/Video (FFmpeg), Audio-AI, Alexa-Integration, Clawbake. Für Content Creator und Medienproduzenten."
PROFILES["KI_Forschung"]="Spezialisierte Bibliotheken für Reinforcement Learning (OpenClaw RL), erweiterte LLM-Modelle (Gemini-1.5-Pro), Flowise/LangFlow. Für KI-Wissenschaftler und Forscher."
PROFILES["Physik"]="Science-Lab-Profil fuer Messdaten, Simulation, JupyterLab, GPU-Auswertung, Paper/PDF-Analyse und OpenClaw-Forschungsagenten."
PROFILES["Chemie"]="Science-Lab-Profil fuer Molekuel- und Reaktionsanalyse, RDKit/Open-Babel-orientierte Workflows, Laborberichte, Dashboards und lokale KI-Unterstuetzung."
PROFILES["Biologie"]="Science-Lab-Profil fuer Omics, Mikroskopie, Laborprotokolle, Home-Assistant-Sensorik, JupyterLab und OpenClaw-Bio-Agenten."
PROFILES["Bioinformatik"]="Science-Lab-Profil fuer Sequenzanalyse, Varianten, Pipelines, Paper-Auswertung, JupyterLab und optionales Kubernetes-Offloading."
PROFILES["Molekuelsimulation"]="Science-Lab-Profil fuer Molekulardynamik, OpenMM/GROMACS/LAMMPS-nahe Workflows, CUDA/ROCm-Erkennung und GPU-Batchjobs."
PROFILES["Robotik_Labor"]="Science-Lab-Profil fuer sichere Laborrobotik, ROS-2-nahe Planung, Sensorintegration, Simulation-first und menschliche Freigabe."
PROFILES["Materialwissenschaft"]="Science-Lab-Profil fuer Materials Informatics, Struktur- und Simulationsdaten, pymatgen/ASE-nahe Analysen und Dashboards."
PROFILES["Mathematik_Simulation"]="Profil fuer Formeln, Optimierung, numerische Simulation, JupyterLab und lokale KI-gestuetzte Erklaerungen."
PROFILES["Astronomie_Space_AI"]="Profil fuer FITS-Dateien, Teleskopdaten, Raumfahrt-Recherche, Bildauswertung, JupyterLab und Paper-Analyse."
PROFILES["Medizinische_Literatur_Recherche"]="Lokales Rechercheprofil fuer medizinische Literatur und Evidenznotizen. Keine Diagnose und keine Therapieentscheidung."
PROFILES["Umwelt_Klima_Energie"]="Profil fuer Klima-, Wetter-, PV-, Batterie-, Energie- und Smart-Home-Auswertungen mit Dashboards."
PROFILES["Personal_Assistant_Local_First"]="Lokaler persoenlicher Assistent mit Ollama, OpenClaw, RAG, Open WebUI, n8n und sicheren Freigabegrenzen."
PROFILES["Voice_Command_Center"]="Lokale Sprachsteuerung mit STT/TTS, Home Assistant, Node-RED und Bestaetigungslogik fuer riskante Aktionen."
PROFILES["Knowledge_Librarian"]="Lokale Wissensverwaltung fuer PDF, Markdown, Office, Scans, Paperless, Docling, Tika, Suche und RAG."
PROFILES["Web_App_Builder"]="Profil fuer lokale WebUIs, Dashboards, Admin-Panels, Vite/React-nahe Entwicklung und DevSecOps-Checks."
PROFILES["Zero_Trust_Remote_Access"]="Profil fuer Tailscale, Cloudflare Tunnel, Firewall, Auth und sichere Remote-Zugriffe ohne offene Admin-Ports."
PROFILES["Kubernetes_GPU_Orchestrator"]="Experimentelles Profil fuer GPU-/Render-/LLM-/Science-Worker mit Monitoring und Kubernetes-Offloading."
PROFILES["Storage_NAS_Backup"]="Profil fuer Modelle, Medien, Dokumente, MinIO, NAS, Restic, BorgBackup, Rclone und Restore-Tests."
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
PROFILES["Memory_Import_Export"]="Importiert und exportiert Chat-, Notiz- und Projekt-Memory lokal als Markdown, JSONL, SQLite oder RAG-Bestand mit Qdrant/ChromaDB."
PROFILES["Voice_Assistant"]="Sprachprofil für STT, TTS, Wakeword, Rhasspy/Wyoming und Smart-Home-nahe Sprachassistenten."
PROFILES["Jarvis_FritzBox_Alexa_Home_Assistant"]="Experimental-Profil fuer ein lokales Jarvis-Brain mit Fritz!Box/Fritz!Fon, Home Assistant, optionaler Alexa-Bridge, MQTT, STT/TTS, Ollama und OpenClaw."
PROFILES["Video_Generation"]="Heavy-Profil für lokale Video-KI, Upscaling, Frame-Interpolation, FFmpeg und GPU-nahe Video-Workflows."
PROFILES["Video_Generation_ComfyUI_Wan"]="Technisches Advanced-Profil fuer ComfyUI, Wan2.x, FFmpeg, WSL2/GPU-Hinweise und lokale Video-KI-Renderpfade."
PROFILES["GameDev_3D_Studio_NEXTLEVEL"]="Optionales lokales AI Game Studio fuer Godot 4.x, Godot-Demos, Blender, ComfyUI, Ollama-NPCs, OpenClaw Game Master, n8n, Multiplayer, Renderfarm und Voice."
PROFILES["CAD_Konstrukteur"]="Optionales lokales CAD-/3D-Druck-Profil fuer FreeCAD, CadQuery, OpenSCAD, Blender-Preview, Ollama-CAD-Code, OpenClaw-Agenten, N8n und Whisper-Kommandos."
PROFILES["Architektur_3D_BIM"]="Optionales lokales Architektur-/BIM-/CAD-/3D-Rendering-Profil fuer FreeCAD, Blender, Bonsai, IFCOpenShell, QGIS, ComfyUI, OpenClaw-Agenten, n8n und Renderfarm-Workflows."
PROFILES["Robotertechnik_Anlagensteuerung"]="Simulation-first-Profil fuer ROS 2, Gazebo, MoveIt 2, digitale Zwillinge, Anlagenmonitoring, MQTT/OPC UA/Modbus, OpenClaw-Diagnoseagenten und sichere Freigabeprozesse."
PROFILES["OpenHiggsStack_AI_Cinema_Studio"]="Optionales AI-Cinema-/Marketing-Studio als offene Alternative zu Higgsfield: OpenClaw, Ollama, ComfyUI, Wan2.x, FFmpeg und n8n."
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
        dialog --clear --backtitle "$APP_TITLE" \
        --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
        --title "BASIS-INSTALLATION FEHLT" \
        --msgbox "Hinweis: Ollama und/oder OpenClaw sind aktuell noch nicht vollständig installiert.\n\nDie Profilverwaltung kann trotzdem geöffnet werden. Einige Profile benötigen für die volle Funktion aber die Basis-Installation.\n\nEmpfehlung: Öffne zuerst die Basis-Installation, wenn Profile direkt mit Ollama/OpenClaw arbeiten sollen.\n\nDrücke Enter, um die Profilverwaltung trotzdem zu öffnen." 14 86
        reset_terminal_display
    fi

    declare -A INSTALLED_PROFILES_MAP
    load_installed_map "$PROFILE_STATUS_FILE" INSTALLED_PROFILES_MAP
    local profile_menu_total_summary
    local profile_menu_prompt
    local overview_metrics_enabled="false"
    if is_preference_enabled "${OVERVIEW_METRICS_ENABLED:-true}"; then
        overview_metrics_enabled="true"
    fi
    if [ "$overview_metrics_enabled" = "true" ]; then
        profile_menu_total_summary="$(summarize_operation_metrics_with_missing_plain "profile_install" "${PROFILE_KEYS[@]}")"
        profile_menu_prompt="Wählen Sie ein Profil.\n\nSpalten: Status | Zeit hh:mm:ss | Gesamtspeicher MB | Beschreibung\nFehlende Werte: --:--:-- | --.- MB\nErmittelte Summe aller Profil-Installationen: ${profile_menu_total_summary}\n\nIn der Detailansicht können Gesamtprofil oder Einzeltools verwaltet werden:"
    else
        profile_menu_total_summary=""
        profile_menu_prompt="Wählen Sie ein Profil.\n\nZeit- und Speicherwerte sind in den Optionen deaktiviert, damit diese Übersicht schneller lädt.\n\nIn der Detailansicht können Gesamtprofil oder Einzeltools verwaltet werden:"
    fi

    PROFILE_MENU_OPTIONS=()
    for profile_key in "${PROFILE_KEYS[@]}"; do
        local profile_status_text="Nicht installiert"
        local profile_metric_summary
        local profile_storage_summary
        if [ -n "$profile_key" ] && [ "${INSTALLED_PROFILES_MAP[$profile_key]:-}" = "1" ]; then
            profile_status_text="Installiert"
        fi
        if [ "$overview_metrics_enabled" = "true" ]; then
            profile_metric_summary="$(get_operation_metric_summary_plain "profile_install_${profile_key}")"
            PROFILE_MENU_OPTIONS+=("$profile_key" "[$profile_status_text] ${profile_metric_summary} | ${PROFILES[$profile_key]}")
        else
            PROFILE_MENU_OPTIONS+=("$profile_key" "[$profile_status_text] ${PROFILES[$profile_key]}")
        fi
    done

    while true; do
        dialog --clear --backtitle "$APP_TITLE" \
        --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
        --title "PROFIL-MANAGEMENT" --menu "$profile_menu_prompt" 30 120 18 \
        "${PROFILE_MENU_OPTIONS[@]}" \
        "ZURUECK" "${TXT_BACK_ITEM:-Zurück} zum Profil-Hub" 2> /tmp/profile_selection

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
        if [ "$overview_metrics_enabled" = "true" ]; then
            profile_menu_total_summary="$(summarize_operation_metrics_with_missing_plain "profile_install" "${PROFILE_KEYS[@]}")"
            profile_menu_prompt="Wählen Sie ein Profil.\n\nSpalten: Status | Zeit hh:mm:ss | Gesamtspeicher MB | Beschreibung\nFehlende Werte: --:--:-- | --.- MB\nErmittelte Summe aller Profil-Installationen: ${profile_menu_total_summary}\n\nIn der Detailansicht können Gesamtprofil oder Einzeltools verwaltet werden:"
        fi
        PROFILE_MENU_OPTIONS=()
        for profile_key in "${PROFILE_KEYS[@]}"; do
            local refreshed_status_text="Nicht installiert"
            local refreshed_metric_summary
            local refreshed_storage_summary
            if [ -n "$profile_key" ] && [ "${INSTALLED_PROFILES_MAP[$profile_key]:-}" = "1" ]; then
                refreshed_status_text="Installiert"
            fi
            if [ "$overview_metrics_enabled" = "true" ]; then
                refreshed_metric_summary="$(get_operation_metric_summary_plain "profile_install_${profile_key}")"
                PROFILE_MENU_OPTIONS+=("$profile_key" "[$refreshed_status_text] ${refreshed_metric_summary} | ${PROFILES[$profile_key]}")
            else
                PROFILE_MENU_OPTIONS+=("$profile_key" "[$refreshed_status_text] ${PROFILES[$profile_key]}")
            fi
        done
    done
}

# --- Funktionen für Tool-Management ---

declare -A TOOLS
declare -A TOOL_SCRIPT_NAMES
TOOL_KEYS=("Ollama" "OpenClaw" "Ruflo" "Act" "Actionlint" "Activepieces" "Agent_Router" "Ahrefs" "AI_Powered_Law_Firms" "Aider" "Airbyte" "Airtable" "AnimateDiff" "Ansible" "Apache_Tika" "ArgoCD_CLI" "Authentik" "Authelia" "AutoGen" "AutoGPT" "Axolotl" "Backtest_Workflow" "Blender" "BPM_Analyzer" "Browser_Tool" "Buffer_API" "cAdvisor" "Changelog_Generator" "ChromaDB" "Clawbake" "Clawhub" "Clawhub_CLI" "Code_Sandbox" "ComfyUI" "Continue_Dev" "ControlNet" "Coqui_TTS" "CrewAI" "Data_Juicer" "dbt" "Deadline_Checker" "Demucs" "Docker" "Docker_Compose_Plugin" "Docling" "Drafting_Agent" "DuckDB" "ElevenLabs" "Emotion_Tagging" "EnviroLLM" "Ethers_JS" "EULLM" "Exchange_APIs" "Fail2Ban" "Fail2Ban_Analyzer" "Faster_Whisper" "FFmpeg" "File_System_Tool" "FinGPT" "FinRAG" "FinRobot" "Firecrawl" "Flowise" "Flux_CLI" "Fooocus" "Foundry" "GFPGAN" "GitHub_API_Tooling" "GitHub_CLI" "GitHub_Research" "Gitleaks" "Google_Analytics_API" "Grafana" "Grafana_Alloy" "Grype" "Guardrails_AI" "Hadolint" "Hardhat" "Healthchecks" "Helm" "Home_Assistant" "Hook_Detection" "HubSpot" "Huge_Facing" "Huginn" "Image_Upscaler_Pipeline" "InvokeAI" "Joplin_CLI" "JupyterLab" "K3s" "K9s" "Kimi2" "Kubectl" "Kubectx_Kubens" "Kubernetes" "Kustomize" "LangChain" "LangFlow" "Langfuse" "LangGraph" "Lawfirm" "LibreOffice_Headless" "librosa" "LiteLLM" "Llama_CPP" "Llama_CPP_Toolchain" "LLaMA_Factory" "LlamaIndex" "Loki" "Make" "Mail_Utils_MSMTP" "Markdownlint_CLI" "Marker" "MCPO" "Meilisearch" "Memory_Policies" "Meta_Ads_API" "Metabase" "MinIO" "MLflow" "Mosquitto" "Music2P_Pipeline" "MusicGen" "n8n" "NATS" "Neo4j" "Netdata" "Nikto" "Nmap" "Node_Exporter" "Node_Red" "Notion" "OCRmyPDF" "OPA" "Open_WebUI" "OpenClaw_RL" "OpenCode" "OpenHands" "OpenLIT" "OpenManus" "OpenTelemetry" "OpenTofu" "openWakeWord" "Pandoc" "Paperless_NGX" "PDF_Parser" "Pgvector" "Pipedream" "Piper" "Playwright" "Podman" "Postgres" "Pre_Commit" "Prefect" "Prometheus" "Promptfoo" "Puppeteer" "pydub" "Qdrant" "RabbitMQ" "Ray" "Rclone" "RealESRGAN" "Redis" "Release_Please" "Rembg" "Repo_Comparison" "Restic" "Rhasspy" "RIFE" "Riffusion" "Risk_Agent" "Risk_Scoring" "Risk_Strategy_Analyzer" "Runway_API" "Security_Workflow" "Semgrep" "SEMrush" "ShellCheck" "Shfmt" "SQLite" "SQLite_Vec" "Stable_Diffusion_WebUI" "Stable_Diffusion_WebUI_Forge" "Stirling_PDF" "Suno_API" "Supabase" "SVD" "Syft" "Syncthing" "Tax_Calculator" "Tax_Law_Agent" "Tesseract" "Thumbnail_Pipeline" "TikTok_Ads_API" "TikTok_Score" "Trend_Monitor" "Trivy" "TruffleHog" "Udio_API" "Unsloth" "Unstructured" "Upload_Automation" "Uptime_Kuma" "Vault" "Velero" "vLLM" "Voice_Assistant_Runtime" "VS_Code_Server" "Weaviate" "Web3_APIs" "Web3_Py" "Weights_and_Biases" "Whisper" "Whisper_CPP" "Wyoming" "YT_DLP" "Zapier" "Zenbot_API" "Zenbot_trader" "Zotero")
TOOLS["Ollama"]="Lokales LLM-Backend. Du kannst über den Ollama Modell-Manager spezifische Modelle installieren und verwalten. Für weitere Informationen zu den Modellen siehe in der Online-Dokumentation nach."
TOOLS["Ruflo"]="Ruflo/claude-flow-nahe CLI fuer Agenten-Orchestrierung und Hive-Mind-Workflows. Installation nutzt GitHub, Node.js und pnpm; Build-Skripte werden nur nach gezielter Freigabe erlaubt."
TOOLS["Authentik"]="Optionaler Identity Provider fuer OIDC/OAuth2, SSO und zentrale Logins vor internen Webdiensten. Bereitet nur sichere lokale Vorlagen vor."
TOOLS["Authelia"]="Optionale schlanke Auth-/MFA-Schicht vor Webdiensten, besonders fuer Reverse Proxy, MiniPC, Homelab und VPS geeignet. Bereitet nur lokale Vorlagen vor."
TOOLS["OpenManus"]="KI-Agenten-Framework für automatisierte Aufgaben wie Web-Recherche und Datenanalyse."
TOOLS["OpenClaw"]="Fortschrittliches KI-Agenten-Framework mit Reinforcement Learning (RL) und Skill-Integration (z.B. gcali)."
TOOLS["Clawhub_CLI"]="Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten, dem zentralen Hub für KI-Agenten."
TOOLS["OpenClaw_RL"]="Reinforcement Learning Erweiterung für OpenClaw, ermöglicht dem Agenten das Lernen durch Interaktion."
TOOLS["Clawbake"]="Experimental: Kubernetes-/OpenClaw-Operator-Projekt. Installer bereitet Quelle/Go-Build vor; echter Betrieb braucht K3s/Kubernetes, PostgreSQL, Helm-Values und OIDC-Secrets."
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
TOOLS["Mail_Utils_MSMTP"]="Lokale Mailausgabe fuer Diagnoseberichte ueber mailutils/msmtp. Installiert keine Zugangsdaten und nutzt nur lokale Benutzerkonfiguration."
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
TOOL_SCRIPT_NAMES["Ruflo"]="ruflo"
TOOL_SCRIPT_NAMES["Authentik"]="authentik"
TOOL_SCRIPT_NAMES["Authelia"]="authelia"
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
TOOL_SCRIPT_NAMES["Mail_Utils_MSMTP"]="mail_utils_msmtp"
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

    if ! validate_tool_source_policy "$tool_key" "$action"; then
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
    local operation_status="failed"
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
    maybe_cleanup_logs_before_operation
    begin_operation_measurement "tool_install_${TOOL_KEY}" "Tool installieren: ${TOOL_KEY}"
    echo -e "${BLUE}Installiere Tool: ${TOOL_KEY}...${NC}"
    if ! preflight_tool_install_storage "$TOOL_KEY"; then
        end_operation_measurement "failed"
        echo -e "${RED}Tool '${TOOL_KEY}' wurde vor dem Start wegen zu wenig freiem Speicher nicht installiert.${NC}"
        handle_manual_tool_post_action "$TOOL_KEY" "Installation" "$operation_status" "${TOOL_BATCH_UPCOMING_PREVIEW:-}"
        return 1
    fi
    if [ "$TOOL_KEY" = "Huginn" ]; then
        echo -e "${YELLOW}Huginn nutzt die Benutzerkonfiguration aus ~/.openclaw_ultimate_user_data/huginn/.${NC}"
        echo -e "${YELLOW}Dort liegen HUGINN_REPO_REF, Datenbankauswahl und .env.template bewusst ausserhalb des Repos.${NC}"
    fi
    run_tool_script "$TOOL_KEY" "install"
    if [ $? -eq 0 ]; then
        append_unique_line "$TOOL_STATUS_FILE" "$TOOL_KEY"
        end_operation_measurement "success"
        operation_status="success"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich installiert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Installation von Tool \'$TOOL_KEY\'.${NC}"
    fi
    handle_manual_tool_post_action "$TOOL_KEY" "Installation" "$operation_status" "${TOOL_BATCH_UPCOMING_PREVIEW:-}"
}

# Funktion zum Deinstallieren eines Tools
uninstall_tool() {
    local TOOL_KEY="$1"
    local operation_status="failed"
    show_tool_action_intro "$TOOL_KEY" "deinstallieren" "uninstall"
    maybe_cleanup_logs_before_operation
    begin_operation_measurement "tool_uninstall_${TOOL_KEY}" "Tool deinstallieren: ${TOOL_KEY}"
    echo -e "${BLUE}Deinstalliere Tool: ${TOOL_KEY}...${NC}"
    echo -e "${YELLOW}Achtung:${NC} Die Deinstallation entfernt in der Regel nur das Tool selbst."
    echo -e "${YELLOW}Hinweis:${NC} Abhängigkeiten, Build-Apps, Paket-Caches und andere Zusätze bleiben erhalten."
    echo -e "${YELLOW}Aufräumen:${NC} Bitte danach in den Optionen unter Installationsüberwachung die Installationsreste-/Cache-Bereinigung prüfen."
    run_tool_script "$TOOL_KEY" "uninstall"
    if [ $? -eq 0 ]; then
        remove_exact_line "$TOOL_STATUS_FILE" "$TOOL_KEY"
        remove_tool_from_autostart_script "$TOOL_KEY"
        end_operation_measurement "success"
        operation_status="success"
        echo -e "${GREEN}Tool \'$TOOL_KEY\' erfolgreich deinstalliert.${NC}"
    else
        end_operation_measurement "failed"
        echo -e "${RED}Fehler bei der Deinstallation von Tool \'$TOOL_KEY\'.${NC}"
    fi
    handle_manual_tool_post_action "$TOOL_KEY" "Deinstallation" "$operation_status" "${TOOL_BATCH_UPCOMING_PREVIEW:-}"
}

# Funktion zum Anzeigen des Tool-Management-Menüs
show_tool_management_menu() {
    local tool_menu_started_at
    local tool_menu_free_kb_before
    tool_menu_started_at="$(date +%s)"
    tool_menu_free_kb_before="$(get_free_disk_kb)"
    TOOL_BATCH_ABORT_REQUESTED=0
    sync_core_tool_status
    ensure_user_workspace
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"

    # Installierte Tools laden
    declare -A INSTALLED_TOOLS_MAP
    local total_tool_count=0
    local installed_tool_count=0
    local tool_menu_total_summary
    local tool_menu_prompt
    local overview_metrics_enabled="false"
    load_installed_map "$TOOL_STATUS_FILE" INSTALLED_TOOLS_MAP
    total_tool_count="${#TOOL_KEYS[@]}"
    if is_preference_enabled "${OVERVIEW_METRICS_ENABLED:-true}"; then
        overview_metrics_enabled="true"
        tool_menu_total_summary="$(summarize_operation_metrics_with_missing_plain "tool_install" "${TOOL_KEYS[@]}")"
        tool_menu_prompt="(*) = behalten oder installieren.\n\nSpalten: Auswahl | Tool | Zeit hh:mm:ss | Gesamtspeicher MB | Beschreibung\nFehlende Werte: --:--:-- | --.- MB\nErmittelte Summe aller Tool-Installationen: ${tool_menu_total_summary}\nAusführung: erst Deinstallationen, danach Installationen.\nGesamt: ${total_tool_count} | Installiert: ${installed_tool_count}"
    else
        overview_metrics_enabled="false"
        tool_menu_total_summary=""
        tool_menu_prompt="(*) = behalten oder installieren.\n\nZeit- und Speicherwerte sind in den Optionen deaktiviert, damit diese Übersicht schneller lädt.\nAusführung: erst Deinstallationen, danach Installationen.\nGesamt: ${total_tool_count} | Installiert: ${installed_tool_count}"
    fi

    TOOL_CHECKLIST_OPTIONS=()
    for tool_key in "${TOOL_KEYS[@]}"; do
        STATUS="off"
        local tool_metric_summary
        local tool_storage_summary
        if [ -n "$tool_key" ] && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" = "1" ]; then
            STATUS="on"
            installed_tool_count=$((installed_tool_count + 1))
        fi
        if [ "$overview_metrics_enabled" = "true" ]; then
            tool_metric_summary="$(get_operation_metric_summary_plain "tool_install_${tool_key}")"
            TOOL_CHECKLIST_OPTIONS+=("$tool_key" "${tool_metric_summary} | ${TOOLS[$tool_key]}" "$STATUS")
        else
            TOOL_CHECKLIST_OPTIONS+=("$tool_key" "${TOOLS[$tool_key]}" "$STATUS")
        fi
    done
    if [ "$overview_metrics_enabled" != "true" ]; then
        tool_menu_prompt="(*) = behalten oder installieren.\n\nZeit- und Speicherwerte sind in den Optionen deaktiviert, damit diese Übersicht schneller lädt.\nAusführung: erst Deinstallationen, danach Installationen.\nGesamt: ${total_tool_count} | Installiert: ${installed_tool_count}"
    else
        tool_menu_prompt="(*) = behalten oder installieren.\n\nSpalten: Auswahl | Tool | Zeit hh:mm:ss | Gesamtspeicher MB | Beschreibung\nFehlende Werte: --:--:-- | --.- MB\nErmittelte Summe aller Tool-Installationen: ${tool_menu_total_summary}\nAusführung: erst Deinstallationen, danach Installationen.\nGesamt: ${total_tool_count} | Installiert: ${installed_tool_count}"
    fi

    if [ "$overview_metrics_enabled" = "true" ]; then
        record_menu_load_measurement "menu_load_tool_management_metrics_on" "Tool-Menue laden (Zeit-/Speicherwerte aktiv)" "$tool_menu_started_at" "$tool_menu_free_kb_before"
    else
        record_menu_load_measurement "menu_load_tool_management_metrics_off" "Tool-Menue laden (Zeit-/Speicherwerte inaktiv)" "$tool_menu_started_at" "$tool_menu_free_kb_before"
    fi

    dialog --clear --backtitle "$APP_TITLE" \
    --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
    --title "TOOL-MANAGEMENT (${installed_tool_count}/${total_tool_count} installiert)" --checklist "$tool_menu_prompt" 34 120 24 \
    "${TOOL_CHECKLIST_OPTIONS[@]}" 2> /tmp/tool_selection

    if [ $? -ne 0 ]; then
        return 0
    fi

    mapfile -t SELECTED_TOOLS_ARRAY < <(tr ' ' '\n' < /tmp/tool_selection | tr -d '"' | sed '/^$/d')

    local -a tools_to_uninstall=()
    local -a tools_to_install=()

    # Erst Deinstallationen planen, dann Installationen. So wird Speicher
    # freigegeben, bevor neue, oft grosse Abhaengigkeiten geladen werden.
    for tool_key in "${TOOL_KEYS[@]}"; do
        if ! selection_contains "$tool_key" "${SELECTED_TOOLS_ARRAY[@]}" && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" = "1" ]; then
            tools_to_uninstall+=("$tool_key")
        fi
    done

    for tool_key in "${TOOL_KEYS[@]}"; do
        if selection_contains "$tool_key" "${SELECTED_TOOLS_ARRAY[@]}" && [ "${INSTALLED_TOOLS_MAP[$tool_key]:-}" != "1" ]; then
            tools_to_install+=("$tool_key")
        fi
    done

    if ! run_ordered_tool_actions "Tool-Management" tools_to_uninstall tools_to_install; then
        return 0
    fi

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

SCIENCE_CORE_TOOLS="Ollama OpenClaw JupyterLab Docling Apache_Tika"
SCIENCE_EXTENDED_TOOLS="Whisper_CPP Grafana Prometheus n8n"
SCIENCE_INTEGRATION_TOOLS="Kubernetes K3s Home_Assistant Mosquitto"

PROFILE_CORE_TOOLS["Physik"]="$SCIENCE_CORE_TOOLS"
PROFILE_EXTENDED_TOOLS["Physik"]="$SCIENCE_EXTENDED_TOOLS"
PROFILE_INTEGRATION_TOOLS["Physik"]="$SCIENCE_INTEGRATION_TOOLS"
PROFILE_SPECIAL_TOOLS["Physik"]="Ollama OpenClaw JupyterLab Docling Apache_Tika Whisper_CPP"
PROFILE_SPECIAL_LABELS["Physik"]="Physik Science Lab"

PROFILE_CORE_TOOLS["Chemie"]="$SCIENCE_CORE_TOOLS"
PROFILE_EXTENDED_TOOLS["Chemie"]="$SCIENCE_EXTENDED_TOOLS"
PROFILE_INTEGRATION_TOOLS["Chemie"]="$SCIENCE_INTEGRATION_TOOLS"
PROFILE_SPECIAL_TOOLS["Chemie"]="Ollama OpenClaw JupyterLab Docling Apache_Tika Whisper_CPP"
PROFILE_SPECIAL_LABELS["Chemie"]="Chemie Science Lab"

PROFILE_CORE_TOOLS["Biologie"]="$SCIENCE_CORE_TOOLS"
PROFILE_EXTENDED_TOOLS["Biologie"]="$SCIENCE_EXTENDED_TOOLS"
PROFILE_INTEGRATION_TOOLS["Biologie"]="$SCIENCE_INTEGRATION_TOOLS"
PROFILE_SPECIAL_TOOLS["Biologie"]="Ollama OpenClaw JupyterLab Docling Apache_Tika Whisper_CPP Home_Assistant Mosquitto"
PROFILE_SPECIAL_LABELS["Biologie"]="Biologie Science Lab"

PROFILE_CORE_TOOLS["Bioinformatik"]="$SCIENCE_CORE_TOOLS"
PROFILE_EXTENDED_TOOLS["Bioinformatik"]="$SCIENCE_EXTENDED_TOOLS"
PROFILE_INTEGRATION_TOOLS["Bioinformatik"]="$SCIENCE_INTEGRATION_TOOLS"
PROFILE_SPECIAL_TOOLS["Bioinformatik"]="Ollama OpenClaw JupyterLab Docling Apache_Tika Whisper_CPP"
PROFILE_SPECIAL_LABELS["Bioinformatik"]="Bioinformatik Science Lab"

PROFILE_CORE_TOOLS["Molekuelsimulation"]="$SCIENCE_CORE_TOOLS"
PROFILE_EXTENDED_TOOLS["Molekuelsimulation"]="$SCIENCE_EXTENDED_TOOLS"
PROFILE_INTEGRATION_TOOLS["Molekuelsimulation"]="$SCIENCE_INTEGRATION_TOOLS"
PROFILE_SPECIAL_TOOLS["Molekuelsimulation"]="Ollama OpenClaw JupyterLab Docling Apache_Tika Whisper_CPP"
PROFILE_SPECIAL_LABELS["Molekuelsimulation"]="Molekuelsimulation Science Lab"

PROFILE_CORE_TOOLS["Robotik_Labor"]="$SCIENCE_CORE_TOOLS"
PROFILE_EXTENDED_TOOLS["Robotik_Labor"]="$SCIENCE_EXTENDED_TOOLS"
PROFILE_INTEGRATION_TOOLS["Robotik_Labor"]="$SCIENCE_INTEGRATION_TOOLS"
PROFILE_SPECIAL_TOOLS["Robotik_Labor"]="Ollama OpenClaw JupyterLab Docling Apache_Tika Whisper_CPP Home_Assistant Mosquitto"
PROFILE_SPECIAL_LABELS["Robotik_Labor"]="Robotik Labor Science Lab"

PROFILE_CORE_TOOLS["Materialwissenschaft"]="$SCIENCE_CORE_TOOLS"
PROFILE_EXTENDED_TOOLS["Materialwissenschaft"]="$SCIENCE_EXTENDED_TOOLS"
PROFILE_INTEGRATION_TOOLS["Materialwissenschaft"]="$SCIENCE_INTEGRATION_TOOLS"
PROFILE_SPECIAL_TOOLS["Materialwissenschaft"]="Ollama OpenClaw JupyterLab Docling Apache_Tika Whisper_CPP"
PROFILE_SPECIAL_LABELS["Materialwissenschaft"]="Materialwissenschaft Science Lab"

PROFILE_CORE_TOOLS["Mathematik_Simulation"]="Ollama OpenClaw JupyterLab"
PROFILE_EXTENDED_TOOLS["Mathematik_Simulation"]="Grafana Prometheus"
PROFILE_INTEGRATION_TOOLS["Mathematik_Simulation"]="Kubernetes"

PROFILE_CORE_TOOLS["Astronomie_Space_AI"]="Ollama OpenClaw JupyterLab Docling"
PROFILE_EXTENDED_TOOLS["Astronomie_Space_AI"]="Grafana Prometheus"
PROFILE_INTEGRATION_TOOLS["Astronomie_Space_AI"]="Kubernetes"

PROFILE_CORE_TOOLS["Medizinische_Literatur_Recherche"]="Ollama OpenClaw Docling Apache_Tika Paperless_NGX Qdrant"
PROFILE_EXTENDED_TOOLS["Medizinische_Literatur_Recherche"]="Meilisearch Pandoc"
PROFILE_INTEGRATION_TOOLS["Medizinische_Literatur_Recherche"]=""

PROFILE_CORE_TOOLS["Umwelt_Klima_Energie"]="Home_Assistant Grafana Prometheus Netdata JupyterLab"
PROFILE_EXTENDED_TOOLS["Umwelt_Klima_Energie"]="n8n Node_RED"
PROFILE_INTEGRATION_TOOLS["Umwelt_Klima_Energie"]="Mosquitto"

PROFILE_CORE_TOOLS["Personal_Assistant_Local_First"]="Ollama OpenClaw Open_WebUI Qdrant n8n"
PROFILE_EXTENDED_TOOLS["Personal_Assistant_Local_First"]="Paperless_NGX Docling"
PROFILE_INTEGRATION_TOOLS["Personal_Assistant_Local_First"]="Tailscale"

PROFILE_CORE_TOOLS["Voice_Command_Center"]="Whisper_CPP Faster_Whisper Piper Coqui_TTS"
PROFILE_EXTENDED_TOOLS["Voice_Command_Center"]="Home_Assistant Node_RED"
PROFILE_INTEGRATION_TOOLS["Voice_Command_Center"]="Mosquitto"

PROFILE_CORE_TOOLS["Knowledge_Librarian"]="Paperless_NGX Docling Apache_Tika Qdrant Meilisearch Pandoc"
PROFILE_EXTENDED_TOOLS["Knowledge_Librarian"]="Stirling_PDF"
PROFILE_INTEGRATION_TOOLS["Knowledge_Librarian"]="MinIO"

PROFILE_CORE_TOOLS["Web_App_Builder"]="GitHub_CLI Pre_Commit Gitleaks Semgrep Trivy"
PROFILE_EXTENDED_TOOLS["Web_App_Builder"]="Playwright Puppeteer"
PROFILE_INTEGRATION_TOOLS["Web_App_Builder"]="Tailscale Cloudflared"

PROFILE_CORE_TOOLS["Repo_Maintainer_Agent"]="GitHub_CLI Pre_Commit Gitleaks Semgrep Trivy"
PROFILE_EXTENDED_TOOLS["Repo_Maintainer_Agent"]="Release_Please Changelog_Generator"
PROFILE_INTEGRATION_TOOLS["Repo_Maintainer_Agent"]="Act"

PROFILE_CORE_TOOLS["Zero_Trust_Remote_Access"]="Tailscale Cloudflared UFW CrowdSec Fail2Ban"
PROFILE_EXTENDED_TOOLS["Zero_Trust_Remote_Access"]="Authentik Authelia"
PROFILE_INTEGRATION_TOOLS["Zero_Trust_Remote_Access"]="Prometheus Grafana"

PROFILE_CORE_TOOLS["Kubernetes_GPU_Orchestrator"]="Prometheus Grafana Node_Exporter cAdvisor"
PROFILE_EXTENDED_TOOLS["Kubernetes_GPU_Orchestrator"]="K3s"
PROFILE_INTEGRATION_TOOLS["Kubernetes_GPU_Orchestrator"]="Tailscale"

PROFILE_CORE_TOOLS["Storage_NAS_Backup"]="Restic BorgBackup Rclone MinIO"
PROFILE_EXTENDED_TOOLS["Storage_NAS_Backup"]="Grafana Prometheus"
PROFILE_INTEGRATION_TOOLS["Storage_NAS_Backup"]="Tailscale"

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

PROFILE_CORE_TOOLS["Memory_Import_Export"]="Qdrant ChromaDB DuckDB Docling Apache_Tika"
PROFILE_EXTENDED_TOOLS["Memory_Import_Export"]="Open_WebUI"
PROFILE_INTEGRATION_TOOLS["Memory_Import_Export"]="Ollama"

PROFILE_CORE_TOOLS["Voice_Assistant"]="Whisper_CPP Faster_Whisper Piper openWakeWord Mosquitto"
PROFILE_EXTENDED_TOOLS["Voice_Assistant"]="Rhasspy Wyoming"
PROFILE_INTEGRATION_TOOLS["Voice_Assistant"]="Node_Red"

PROFILE_CORE_TOOLS["Video_Generation"]="ComfyUI Stable_Diffusion_WebUI_Forge SVD AnimateDiff RIFE RealESRGAN FFmpeg Blender"
PROFILE_EXTENDED_TOOLS["Video_Generation"]="ControlNet"
PROFILE_INTEGRATION_TOOLS["Video_Generation"]="YT_DLP Thumbnail_Pipeline"

PROFILE_CORE_TOOLS["GameDev_3D_Studio_NEXTLEVEL"]="Blender ComfyUI Ollama OpenClaw n8n FFmpeg"
PROFILE_EXTENDED_TOOLS["GameDev_3D_Studio_NEXTLEVEL"]="Whisper_CPP Faster_Whisper Piper Coqui_TTS Qdrant ChromaDB"
PROFILE_INTEGRATION_TOOLS["GameDev_3D_Studio_NEXTLEVEL"]="Kubernetes K3s Cloudflared Tailscale GitHub_CLI Prometheus Grafana"
PROFILE_SPECIAL_TOOLS["GameDev_3D_Studio_NEXTLEVEL"]="Blender ComfyUI Ollama OpenClaw n8n FFmpeg"
PROFILE_SPECIAL_LABELS["GameDev_3D_Studio_NEXTLEVEL"]="AI Game Studio komplett"

PROFILE_CORE_TOOLS["CAD_Konstrukteur"]="Blender Ollama OpenClaw n8n"
PROFILE_EXTENDED_TOOLS["CAD_Konstrukteur"]="Whisper_CPP Faster_Whisper Qdrant ChromaDB"
PROFILE_INTEGRATION_TOOLS["CAD_Konstrukteur"]="Cloudflared Tailscale GitHub_CLI Kubernetes K3s"
PROFILE_SPECIAL_TOOLS["CAD_Konstrukteur"]="Blender Ollama OpenClaw n8n"
PROFILE_SPECIAL_LABELS["CAD_Konstrukteur"]="CAD Konstrukteur komplett"

PROFILE_CORE_TOOLS["Architektur_3D_BIM"]="Blender ComfyUI Ollama OpenClaw n8n"
PROFILE_EXTENDED_TOOLS["Architektur_3D_BIM"]="Qdrant ChromaDB Prometheus Grafana"
PROFILE_INTEGRATION_TOOLS["Architektur_3D_BIM"]="Cloudflared Tailscale GitHub_CLI Kubernetes K3s"
PROFILE_SPECIAL_TOOLS["Architektur_3D_BIM"]="Blender ComfyUI Ollama OpenClaw n8n"
PROFILE_SPECIAL_LABELS["Architektur_3D_BIM"]="Architektur BIM komplett"

PROFILE_CORE_TOOLS["Robotertechnik_Anlagensteuerung"]="Ollama OpenClaw n8n Mosquitto Node_Red Home_Assistant"
PROFILE_EXTENDED_TOOLS["Robotertechnik_Anlagensteuerung"]="Whisper_CPP Prometheus Grafana"
PROFILE_INTEGRATION_TOOLS["Robotertechnik_Anlagensteuerung"]="Kubernetes K3s Cloudflared Tailscale"
PROFILE_SPECIAL_TOOLS["Robotertechnik_Anlagensteuerung"]="Ollama OpenClaw n8n Mosquitto Node_Red Home_Assistant Prometheus Grafana"
PROFILE_SPECIAL_LABELS["Robotertechnik_Anlagensteuerung"]="Robotik & Anlagensteuerung komplett"

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
    local group_metric_summary
    local tool_metric_summary
    local group_prompt
    local overview_metrics_enabled="false"
    local -a group_tool_array=()
    declare -A installed_map

    ensure_user_workspace
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"
    load_installed_map "$TOOL_STATUS_FILE" installed_map

    for tool_key in $tool_list; do
        [ -n "$tool_key" ] || continue
        group_tool_array+=("$tool_key")
        status="off"
        if [ "${installed_map[$tool_key]:-}" = "1" ]; then
            status="on"
        fi
        if is_preference_enabled "${OVERVIEW_METRICS_ENABLED:-true}"; then
            overview_metrics_enabled="true"
            tool_metric_summary="$(get_operation_metric_summary_plain "tool_install_${tool_key}")"
            options+=("$tool_key" "${tool_metric_summary} | ${TOOLS[$tool_key]}" "$status")
        else
            options+=("$tool_key" "${TOOLS[$tool_key]}" "$status")
        fi
    done

    if [ ${#options[@]} -eq 0 ]; then
        dialog --msgbox "${TXT_NO_TOOLS_DEFINED:-Für diesen Block sind aktuell keine Einzeltools definiert.}" 8 60
        return 0
    fi
    if [ "$overview_metrics_enabled" = "true" ]; then
        group_metric_summary="$(summarize_operation_metrics_with_missing_plain "tool_install" "${group_tool_array[@]}")"
        group_prompt="(*) = behalten oder installieren. Leer = bei installierten Tools deinstallieren.\n\nSpalten: Auswahl | Tool | Zeit hh:mm:ss | Gesamtspeicher MB | Beschreibung\nFehlende Werte: --:--:-- | --.- MB\nErmittelte Summe dieses Blocks: ${group_metric_summary}\nAusführung: erst Deinstallationen, danach Installationen."
    else
        group_prompt="(*) = behalten oder installieren. Leer = bei installierten Tools deinstallieren.\n\nZeit- und Speicherwerte sind in den Optionen deaktiviert, damit diese Übersicht schneller lädt.\nAusführung: erst Deinstallationen, danach Installationen."
    fi

    dialog --clear --backtitle "$APP_TITLE" \
    --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
    --title "$group_title" --checklist "$group_prompt" 28 120 18 \
    "${options[@]}" 2> /tmp/profile_block_tools_selection

    if [ $? -ne 0 ]; then
        return 0
    fi

    mapfile -t SELECTED_GROUP_TOOLS < <(tr ' ' '\n' < /tmp/profile_block_tools_selection | tr -d '"' | sed '/^$/d')

    local -a tools_to_uninstall=()
    local -a tools_to_install=()

    # Erst Deinstallationen planen, dann Installationen, damit Speicher vor
    # neuen Downloads/Builds frei wird.
    for tool_key in $tool_list; do
        [ -n "$tool_key" ] || continue
        if ! selection_contains "$tool_key" "${SELECTED_GROUP_TOOLS[@]}" && [ "${installed_map[$tool_key]:-}" = "1" ]; then
            tools_to_uninstall+=("$tool_key")
        fi
    done

    for tool_key in $tool_list; do
        [ -n "$tool_key" ] || continue
        if selection_contains "$tool_key" "${SELECTED_GROUP_TOOLS[@]}" && [ "${installed_map[$tool_key]:-}" != "1" ]; then
            tools_to_install+=("$tool_key")
        fi
    done

    if ! run_ordered_tool_actions "$group_title" tools_to_uninstall tools_to_install; then
        PROFILE_FLOW_ABORT_REQUESTED=1
        return 0
    fi
}

toggle_full_profile_from_block() {
    local profile_key="$1"
    declare -A installed_profiles_map

    ensure_user_workspace
    normalize_status_file "$PROFILE_STATUS_FILE" "${PROFILE_KEYS[@]}"
    load_installed_map "$PROFILE_STATUS_FILE" installed_profiles_map

    if [ "${installed_profiles_map[$profile_key]:-}" = "1" ]; then
        dialog --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" --yesno "Profil '$profile_key' ist aktuell installiert. Möchten Sie das gesamte Profil jetzt deinstallieren?" 8 80
        if [ $? -eq 0 ]; then
            uninstall_profile "$profile_key"
        fi
    else
        dialog --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" --yesno "Profil '$profile_key' ist aktuell nicht installiert. Möchten Sie das gesamte Profil jetzt installieren?" 8 80
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
        dialog --ok-label "${TXT_OK_LABEL:-✔  OK}" --msgbox "Für diesen Block sind aktuell keine Tools definiert." 8 60
        return 0
    fi

    if [ "$all_installed" -eq 1 ]; then
        dialog --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" --yesno "Block '$group_title' ist aktuell installiert. Möchten Sie alle enthaltenen Tools jetzt deinstallieren?" 9 90
        if [ $? -eq 0 ]; then
            for tool_key in $tool_list; do
                [ -n "$tool_key" ] || continue
                [ "${installed_map[$tool_key]:-}" = "1" ] || continue
                uninstall_tool "$tool_key"
                if [ "${TOOL_BATCH_ABORT_REQUESTED:-0}" = "1" ]; then
                    PROFILE_FLOW_ABORT_REQUESTED=1
                    return 0
                fi
            done
        fi
    else
        dialog --yesno "Block '$group_title' ist aktuell nicht vollständig installiert. Möchten Sie alle enthaltenen Tools jetzt installieren?" 9 95
        if [ $? -eq 0 ]; then
            for tool_key in $tool_list; do
                [ -n "$tool_key" ] || continue
                [ "${installed_map[$tool_key]:-}" != "1" ] || continue
                install_tool "$tool_key"
                if [ "${TOOL_BATCH_ABORT_REQUESTED:-0}" = "1" ]; then
                    PROFILE_FLOW_ABORT_REQUESTED=1
                    return 0
                fi
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
            --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
            --title "PROFILBLOCK: $profile_key" --menu "Wählen Sie Block oder Gesamtprofil:" 24 96 10 \
            "1" "Gesamtes Profil installieren/deinstallieren" \
            "2" "Kernmodule (wichtig)" \
            "3" "Erweiterte Module" \
            "4" "Integrationen / Optional" \
            "5" "${special_label} (Einzeltools)" \
            "6" "${special_label} komplett installieren/deinstallieren" \
            "7" "${TXT_BACK_ITEM:-Zurück}" 2> /tmp/profile_block_choice
        else
            dialog --clear --backtitle "$APP_TITLE" \
            --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
            --title "PROFILBLOCK: $profile_key" --menu "Wählen Sie Block oder Gesamtprofil:" 22 90 8 \
            "1" "Gesamtes Profil installieren/deinstallieren" \
            "2" "Kernmodule (wichtig)" \
            "3" "Erweiterte Module" \
            "4" "Integrationen / Optional" \
            "5" "${TXT_BACK_ITEM:-Zurück}" 2> /tmp/profile_block_choice
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
    --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
    --title "PROFILBLÖCKE & EINZELTOOLS" --menu "Wählen Sie einen Profilblock aus:" 26 100 14 \
    "${options[@]}" 2> /tmp/profile_block_profile_choice

    if [ $? -ne 0 ]; then
        return 0
    fi

    show_profile_block_detail_menu "$(cat /tmp/profile_block_profile_choice)"
}

show_profile_management_hub() {
    dialog --clear --backtitle "$APP_TITLE" \
    --cancel-label "${TXT_BACK_LABEL:-↩ Zurück}" \
    --title "PROFIL-MANAGEMENT" --menu "Wählen Sie eine Ansicht:" 18 90 6 \
    "1" "Schnellansicht: komplette Profile" \
    "2" "Blockansicht: Profilblöcke + Einzeltools" \
    "3" "${TXT_BACK_ITEM:-Zurück}" 2> /tmp/profile_management_hub_choice

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
    "────────" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
    "4" "${TXT_MENU_4:-Hybrid: Dein MiniPC + Multi-VPS (Empfohlen)}" \
    "5" "${TXT_MENU_5:-Standalone: Nur VPS (Cloud-Native)}" \
    "6" "${TXT_MENU_6:-Standalone: Nur MiniPC (Lokal)}" \
    "─────────" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
    "7" "${TXT_MENU_7:-Ruflo: Installation & Management}" \
    "──────────" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
    "8" "${TXT_MENU_8:-Tools: Installieren & Deinstallieren}" \
    "9" "${TXT_MENU_9:-Profile: Blöcke, Gesamtprofile & Einzeltools}" \
    "───────────" "${TXT_SEPARATOR_LINE:-────────────────────────────────────────────────────────}" \
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
        ────────*)
            continue
            ;;
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
            local_update_rc=$?
            if [ "$local_update_rc" -eq 0 ]; then end_operation_measurement "success"; else end_operation_measurement "failed"; fi
            if [ "$local_update_rc" -eq 0 ]; then
                read -p "System-Update abgeschlossen. Drücken Sie Enter, um das Setup-Menue neu zu starten..."
                restart_setup_menu_after_update
            fi
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
            "Der OpenClaw-Build mit Ollama kann geschaetzt ${WHITE}${LOCAL_SETUP_TOTAL_ESTIMATE}${YELLOW} dauern.\nEine Eingabe des Ubuntu-Passworts wird kurz nach Beginn der Installation abverlangt.\nIn voraussichtlich ${WHITE}${LOCAL_SETUP_CONFIRM_STOP_1_ESTIMATE}${YELLOW} wird eine manuelle Bestaetigung von dir verlangt, typischerweise beim nachtraeglichen Build von @discordjs/opus.\nDanach geht es auch schon mit Ollama weiter, grob ab ${WHITE}${LOCAL_SETUP_CONFIRM_STOP_2_ESTIMATE}${YELLOW}, inklusive einer erneuten Ubuntu-Passwortabfrage.\nKurz vor ${WHITE}${LOCAL_SETUP_CLOUDFLARE_TOKEN_STOP_ESTIMATE}${YELLOW} wird in der Regel der Cloudflare-Token abgefragt.\nDiese Zwischenstopps gehoeren zur gesamten Zeitmessung mit dazu."
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
        ────────*)
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
            if show_management_loading_notice "Tool-Management" "Es werden Toolstatus, Auswahloptionen und optional die letzten Zeit-/Speicherwerte vorbereitet."; then
                show_tool_management_menu
            fi
            ;;
        9)
            if show_management_loading_notice "Profil-Management" "Es werden Profilstatus, Profilbloecke und optional die letzten Zeit-/Speicherwerte vorbereitet."; then
                show_profile_management_hub
            fi
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
