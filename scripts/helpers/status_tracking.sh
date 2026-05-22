#!/bin/bash
# Gemeinsame Hilfsfunktionen für robuste Statusdateien und direkte Script-Aufrufe.

STATUS_HELPER_ROOT="${HOME}/.openclaw_ultimate_user_data"
PROFILE_STATUS_FILE="$STATUS_HELPER_ROOT/installed_profiles.txt"
TOOL_STATUS_FILE="$STATUS_HELPER_ROOT/installed_tools.txt"
STATUS_HELPER_METRICS_DIR="$STATUS_HELPER_ROOT/metrics_logs"
STATUS_HELPER_METRICS_HISTORY_FILE="$STATUS_HELPER_METRICS_DIR/tool_script_history.tsv"
STATUS_HELPER_METRICS_CONFIG_FILE="$STATUS_HELPER_ROOT/setup_metrics.conf"

PROFILE_KEYS=("Programmierer" "Media_Musik" "KI_Forschung" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht" "Agent_Orchestrator" "Audio" "Content_Automation" "Research_Agent" "Security_Analyst" "Trading_AI" "Visual_Creator" "Memory_Import_Export")
TOOL_KEYS=("Ollama" "OpenClaw" "Act" "Actionlint" "Activepieces" "Agent_Router" "Ahrefs" "AI_Powered_Law_Firms" "Aider" "Airbyte" "Airtable" "AnimateDiff" "Ansible" "Apache_Tika" "ArgoCD_CLI" "AutoGen" "AutoGPT" "Axolotl" "Backtest_Workflow" "Blender" "BPM_Analyzer" "Browser_Tool" "Buffer_API" "cAdvisor" "Changelog_Generator" "ChromaDB" "Clawbake" "Clawhub" "Clawhub_CLI" "Code_Sandbox" "ComfyUI" "Continue_Dev" "ControlNet" "Coqui_TTS" "CrewAI" "Data_Juicer" "dbt" "Deadline_Checker" "Demucs" "Docker" "Docker_Compose_Plugin" "Docling" "Drafting_Agent" "DuckDB" "ElevenLabs" "Emotion_Tagging" "EnviroLLM" "Ethers_JS" "EULLM" "Exchange_APIs" "Fail2Ban" "Fail2Ban_Analyzer" "Faster_Whisper" "FFmpeg" "File_System_Tool" "FinGPT" "FinRAG" "FinRobot" "Firecrawl" "Flowise" "Flux_CLI" "Fooocus" "Foundry" "GFPGAN" "GitHub_API_Tooling" "GitHub_CLI" "GitHub_Research" "Gitleaks" "Google_Analytics_API" "Grafana" "Grafana_Alloy" "Grype" "Guardrails_AI" "Hadolint" "Hardhat" "Healthchecks" "Helm" "Home_Assistant" "Hook_Detection" "HubSpot" "Huge_Facing" "Huginn" "Image_Upscaler_Pipeline" "InvokeAI" "Joplin_CLI" "JupyterLab" "K3s" "K9s" "Kimi2" "Kubectl" "Kubectx_Kubens" "Kubernetes" "Kustomize" "LangChain" "LangFlow" "Langfuse" "LangGraph" "Lawfirm" "LibreOffice_Headless" "librosa" "LiteLLM" "Llama_CPP" "Llama_CPP_Toolchain" "LLaMA_Factory" "LlamaIndex" "Loki" "Make" "Markdownlint_CLI" "Marker" "MCPO" "Meilisearch" "Memory_Policies" "Meta_Ads_API" "Metabase" "MinIO" "MLflow" "Mosquitto" "Music2P_Pipeline" "MusicGen" "n8n" "NATS" "Neo4j" "Netdata" "Nikto" "Nmap" "Node_Exporter" "Node_Red" "Notion" "OCRmyPDF" "OPA" "Open_WebUI" "OpenClaw_RL" "OpenCode" "OpenHands" "OpenLIT" "OpenManus" "OpenTelemetry" "OpenTofu" "openWakeWord" "Pandoc" "Paperless_NGX" "PDF_Parser" "Pgvector" "Pipedream" "Piper" "Playwright" "Podman" "Postgres" "Pre_Commit" "Prefect" "Prometheus" "Promptfoo" "Puppeteer" "pydub" "Qdrant" "RabbitMQ" "Ray" "Rclone" "RealESRGAN" "Redis" "Release_Please" "Rembg" "Repo_Comparison" "Restic" "Rhasspy" "RIFE" "Riffusion" "Risk_Agent" "Risk_Scoring" "Risk_Strategy_Analyzer" "Runway_API" "Security_Workflow" "Semgrep" "SEMrush" "ShellCheck" "Shfmt" "SQLite" "SQLite_Vec" "Stable_Diffusion_WebUI" "Stable_Diffusion_WebUI_Forge" "Stirling_PDF" "Suno_API" "Supabase" "SVD" "Syft" "Syncthing" "Tax_Calculator" "Tax_Law_Agent" "Tesseract" "Thumbnail_Pipeline" "TikTok_Ads_API" "TikTok_Score" "Trend_Monitor" "Trivy" "TruffleHog" "Udio_API" "Unsloth" "Unstructured" "Upload_Automation" "Uptime_Kuma" "Vault" "Velero" "vLLM" "Voice_Assistant_Runtime" "VS_Code_Server" "Weaviate" "Web3_APIs" "Web3_Py" "Weights_and_Biases" "Whisper" "Whisper_CPP" "Wyoming" "YT_DLP" "Zapier" "Zenbot_API" "Zenbot_trader" "Zotero")

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
        if [ -n "${YELLOW:-}" ] && [ -n "${NC:-}" ]; then
            echo -e "${YELLOW}Hinweis: Statusdatei $(basename "$file_path") wurde bereinigt. Sicherung: $backup_file${NC}"
        fi
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

status_tracking_free_kb() {
    df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}'
}

status_tracking_format_kb() {
    local kb="${1:-0}"
    if [ "$kb" -ge 1048576 ] 2>/dev/null; then
        awk -v value="$kb" 'BEGIN {printf "%.1f GB", value/1048576}'
    elif [ "$kb" -ge 1024 ] 2>/dev/null; then
        awk -v value="$kb" 'BEGIN {printf "%.1f MB", value/1024}'
    else
        printf '%s KB' "$kb"
    fi
}

status_tracking_is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

status_tracking_windows_host_free_kb() {
    local drive_name="${WINDOWS_HOST_DRIVE:-C}"
    local free_bytes

    command -v powershell.exe >/dev/null 2>&1 || return 0
    free_bytes="$(powershell.exe -NoProfile -Command "(Get-PSDrive -Name '${drive_name}').Free" 2>/dev/null | tr -d '\r' | awk 'NF {print int($1); exit}')"
    if [ -n "$free_bytes" ] && [ "$free_bytes" -gt 0 ] 2>/dev/null; then
        printf '%s' $((free_bytes / 1024))
    fi
}

status_tracking_print_space_summary() {
    local linux_free_kb="$1"
    local windows_free_kb

    echo "Freier WSL-/Linux-Dateisystemspeicher vor Tool-Skript ${CURRENT_TOOL_KEY}: $(status_tracking_format_kb "${linux_free_kb:-0}")"
    if status_tracking_is_wsl; then
        windows_free_kb="$(status_tracking_windows_host_free_kb)"
        if [ -n "$windows_free_kb" ]; then
            echo "Freier Windows-Host-Speicher (${WINDOWS_HOST_DRIVE:-C}:): $(status_tracking_format_kb "$windows_free_kb")"
            echo "Hinweis: Die WSL-Zahl ist die freie Kapazitaet im Linux-Dateisystem/Mountpoint. Wenn die WSL-Distro auf ${WINDOWS_HOST_DRIVE:-C}: liegt, ist dieser Windows-Wert der praktische Engpass fuer das weitere Wachstum der WSL-VHDX."
            if [ "$windows_free_kb" -lt $((50 * 1024 * 1024)) ] 2>/dev/null; then
                echo "Warnung: Windows meldet weniger als 50 GB frei. Grosse Installationen koennen scheitern oder Windows/WSL instabil machen."
            fi
        fi
    fi
}

status_tracking_metric_prefix() {
    printf '%s' "$1" | tr '[:lower:]- /.' '[:upper:]____'
}

status_tracking_ensure_metrics() {
    mkdir -p "$STATUS_HELPER_METRICS_DIR"
    if [ ! -f "$STATUS_HELPER_METRICS_HISTORY_FILE" ]; then
        printf 'timestamp\ttool\tstatus\tduration_seconds\tfree_kb_before\tfree_kb_after\tdelta_kb\n' > "$STATUS_HELPER_METRICS_HISTORY_FILE"
    fi
    if [ ! -f "$STATUS_HELPER_METRICS_CONFIG_FILE" ]; then
        printf '# Automatisch angelegte Setup-Messwerte\n' > "$STATUS_HELPER_METRICS_CONFIG_FILE"
    fi
}

status_tracking_record_tool_metric() {
    local status="$1"
    local free_after duration_seconds delta_kb metric_prefix tmp_metrics_file

    [ -n "${CURRENT_TOOL_KEY:-}" ] || return 0
    [ -n "${CURRENT_TOOL_TRACKING_STARTED_AT:-}" ] || return 0
    [ "${CURRENT_TOOL_TRACKING_RECORDED:-0}" = "0" ] || return 0

    status_tracking_ensure_metrics
    free_after="$(status_tracking_free_kb)"
    free_after="${free_after:-0}"
    CURRENT_TOOL_TRACKING_FREE_KB_BEFORE="${CURRENT_TOOL_TRACKING_FREE_KB_BEFORE:-$free_after}"
    duration_seconds=$(($(date +%s) - CURRENT_TOOL_TRACKING_STARTED_AT))
    delta_kb=$(( CURRENT_TOOL_TRACKING_FREE_KB_BEFORE - free_after ))

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$CURRENT_TOOL_KEY" \
        "$status" \
        "$duration_seconds" \
        "${CURRENT_TOOL_TRACKING_FREE_KB_BEFORE:-$free_after}" \
        "$free_after" \
        "$delta_kb" >> "$STATUS_HELPER_METRICS_HISTORY_FILE"

    metric_prefix="LAST_TOOL_SCRIPT_$(status_tracking_metric_prefix "$CURRENT_TOOL_KEY")"
    tmp_metrics_file="$(mktemp)"
    grep -Ev "^${metric_prefix}_(TIMESTAMP|STATUS|DURATION_SECONDS|FREE_KB_BEFORE|FREE_KB_AFTER|FREE_GB_BEFORE|FREE_GB_AFTER|DELTA_KB)=" "$STATUS_HELPER_METRICS_CONFIG_FILE" > "$tmp_metrics_file" || true
    {
        printf '\n# Letzte direkte Tool-Skript-Messung fuer %s\n' "$CURRENT_TOOL_KEY"
        printf '%s_TIMESTAMP="%s"\n' "$metric_prefix" "$(date '+%Y-%m-%d %H:%M:%S')"
        printf '%s_STATUS="%s"\n' "$metric_prefix" "$status"
        printf '%s_DURATION_SECONDS="%s"\n' "$metric_prefix" "$duration_seconds"
        printf '%s_FREE_KB_BEFORE="%s"\n' "$metric_prefix" "${CURRENT_TOOL_TRACKING_FREE_KB_BEFORE:-$free_after}"
        printf '%s_FREE_KB_AFTER="%s"\n' "$metric_prefix" "$free_after"
        printf '%s_FREE_GB_BEFORE="%s"\n' "$metric_prefix" "$(( ${CURRENT_TOOL_TRACKING_FREE_KB_BEFORE:-$free_after} / 1024 / 1024 ))"
        printf '%s_FREE_GB_AFTER="%s"\n' "$metric_prefix" "$(( free_after / 1024 / 1024 ))"
        printf '%s_DELTA_KB="%s"\n' "$metric_prefix" "$delta_kb"
    } >> "$tmp_metrics_file"
    mv "$tmp_metrics_file" "$STATUS_HELPER_METRICS_CONFIG_FILE"

    CURRENT_TOOL_TRACKING_RECORDED=1
}

status_tracking_record_tool_exit() {
    local exit_code="$?"
    if [ "${CURRENT_TOOL_TRACKING_RECORDED:-0}" = "0" ] && [ -n "${CURRENT_TOOL_KEY:-}" ]; then
        if [ "$exit_code" -eq 0 ]; then
            status_tracking_record_tool_metric "success"
        else
            status_tracking_record_tool_metric "failed"
        fi
    fi
    return "$exit_code"
}

status_tracking_is_tool_install_script() {
    case "$(basename "${0:-}")" in
        *_install.sh)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

status_tracking_add_unique_package() {
    local package_name="$1"
    local existing

    [ -n "$package_name" ] || return 0

    for existing in "${STATUS_TRACKING_REQUIRED_APT_PACKAGES[@]:-}"; do
        if [ "$existing" = "$package_name" ]; then
            return 0
        fi
    done

    STATUS_TRACKING_REQUIRED_APT_PACKAGES+=("$package_name")
}

status_tracking_infer_base_packages_from_script() {
    local script_path="${1:-}"
    local script_text

    STATUS_TRACKING_REQUIRED_APT_PACKAGES=()

    [ -n "$script_path" ] && [ -f "$script_path" ] || return 0
    script_text="$(cat "$script_path" 2>/dev/null || true)"
    [ -n "$script_text" ] || return 0

    if printf '%s\n' "$script_text" | grep -Eq 'git[[:space:]]+clone|git[[:space:]]+-C|github\.com'; then
        status_tracking_add_unique_package "git"
    fi

    if printf '%s\n' "$script_text" | grep -Eq 'python3?[[:space:]]+-m[[:space:]]+venv|virtualenv|source .*/venv/bin/activate|source .*/\.venv/bin/activate'; then
        status_tracking_add_unique_package "python3"
        status_tracking_add_unique_package "python3-venv"
        status_tracking_add_unique_package "python3-pip"
    fi

    if printf '%s\n' "$script_text" | grep -Eq 'pip3?([[:space:]]|$)|python3?[[:space:]]+-m[[:space:]]+pip'; then
        status_tracking_add_unique_package "python3"
        status_tracking_add_unique_package "python3-pip"
    fi

    if printf '%s\n' "$script_text" | grep -Eq 'build-essential|node-gyp|prebuild-install|gcc|g\+\+|make([[:space:]]|$)|cmake|pkg-config'; then
        status_tracking_add_unique_package "build-essential"
        status_tracking_add_unique_package "pkg-config"
    fi

    if printf '%s\n' "$script_text" | grep -Eq 'cmake'; then
        status_tracking_add_unique_package "cmake"
    fi

    if printf '%s\n' "$script_text" | grep -Eq 'npm[[:space:]]|pnpm[[:space:]]|corepack|yarn[[:space:]]'; then
        status_tracking_add_unique_package "nodejs"
        status_tracking_add_unique_package "npm"
    fi

    if printf '%s\n' "$script_text" | grep -Eq 'go[[:space:]]+(build|install|test)|GOBIN|go install'; then
        status_tracking_add_unique_package "golang-go"
    fi

    if printf '%s\n' "$script_text" | grep -Eq 'cargo[[:space:]]+(build|install)|rustup'; then
        status_tracking_add_unique_package "cargo"
    fi
}

status_tracking_install_missing_base_packages() {
    local missing_packages=()
    local package_name

    [ "${AUTO_INSTALL_TOOL_BASE_DEPS:-true}" = "true" ] || return 0
    status_tracking_is_tool_install_script || return 0
    command -v apt-get >/dev/null 2>&1 || return 0

    status_tracking_infer_base_packages_from_script "${0:-}"

    for package_name in "${STATUS_TRACKING_REQUIRED_APT_PACKAGES[@]:-}"; do
        if [ "$package_name" = "docker-compose-plugin" ]; then
            echo -e "\033[1;33mHinweis: docker-compose-plugin wird nicht direkt per Ubuntu-apt installiert; Docker Compose wird bei Bedarf als CLI-Plugin aus GitHub bereitgestellt.\033[0m"
            continue
        fi
        if ! dpkg -s "$package_name" >/dev/null 2>&1; then
            missing_packages+=("$package_name")
        fi
    done

    [ "${#missing_packages[@]}" -gt 0 ] || return 0

    echo -e "\033[0;34mBasis-Abhaengigkeiten fuer frisches Ubuntu erkannt: ${missing_packages[*]}\033[0m"
    echo -e "\033[1;33mHinweis: Primaerquellen bleiben GitHub; apt installiert hier nur notwendige System-/Build-Werkzeuge.\033[0m"
    sudo apt-get update
    sudo apt-get install -y "${missing_packages[@]}"
}

init_profile_tracking() {
    CURRENT_PROFILE_KEY="$1"
    normalize_status_file "$PROFILE_STATUS_FILE" "${PROFILE_KEYS[@]}"
}

mark_current_profile_installed() {
    [ -n "${CURRENT_PROFILE_KEY:-}" ] || return 1
    append_unique_line "$PROFILE_STATUS_FILE" "$CURRENT_PROFILE_KEY"
}

mark_current_profile_removed() {
    [ -n "${CURRENT_PROFILE_KEY:-}" ] || return 1
    remove_exact_line "$PROFILE_STATUS_FILE" "$CURRENT_PROFILE_KEY"
}

init_tool_tracking() {
    CURRENT_TOOL_KEY="$1"
    normalize_status_file "$TOOL_STATUS_FILE" "${TOOL_KEYS[@]}"
    CURRENT_TOOL_TRACKING_STARTED_AT="$(date +%s)"
    CURRENT_TOOL_TRACKING_FREE_KB_BEFORE="$(status_tracking_free_kb)"
    CURRENT_TOOL_TRACKING_RECORDED=0
    status_tracking_ensure_metrics
    status_tracking_print_space_summary "${CURRENT_TOOL_TRACKING_FREE_KB_BEFORE:-0}"
    status_tracking_install_missing_base_packages
    trap status_tracking_record_tool_exit EXIT
}

mark_current_tool_installed() {
    [ -n "${CURRENT_TOOL_KEY:-}" ] || return 1
    append_unique_line "$TOOL_STATUS_FILE" "$CURRENT_TOOL_KEY"
    status_tracking_record_tool_metric "success"
}

mark_current_tool_removed() {
    [ -n "${CURRENT_TOOL_KEY:-}" ] || return 1
    remove_exact_line "$TOOL_STATUS_FILE" "$CURRENT_TOOL_KEY"
    status_tracking_record_tool_metric "removed"
}
