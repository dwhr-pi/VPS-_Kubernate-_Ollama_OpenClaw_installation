#!/bin/bash
# Gemeinsame Hilfsfunktionen für robuste Statusdateien und direkte Script-Aufrufe.

STATUS_HELPER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROFILE_STATUS_FILE="$STATUS_HELPER_ROOT/installed_profiles.txt"
TOOL_STATUS_FILE="$STATUS_HELPER_ROOT/installed_tools.txt"

PROFILE_KEYS=("Programmierer" "Media_Musik" "KI_Forschung" "Texter_Werbung_Marketing" "Rechtsberatung_Steuerrecht" "Agent_Orchestrator" "Audio" "Content_Automation" "Research_Agent" "Security_Analyst" "Trading_AI" "Visual_Creator")
TOOL_KEYS=("Ollama" "OpenManus" "OpenClaw" "Clawhub_CLI" "OpenClaw_RL" "Clawbake" "n8n" "Activepieces" "Flowise" "LangFlow" "AutoGPT" "Pipedream" "Huginn" "FFmpeg" "LangGraph" "CrewAI" "AutoGen" "Playwright" "ChromaDB" "LangChain" "LlamaIndex" "MLflow" "Whisper" "librosa" "pydub" "Demucs" "Zenbot_trader" "Kimi2" "Clawhub" "Huge_Facing" "Zotero" "Piper" "Coqui_TTS" "YT_DLP" "Web3_APIs" "Exchange_APIs" "Nmap" "Nikto" "Trivy" "Fail2Ban" "Stable_Diffusion_WebUI" "ComfyUI" "RealESRGAN" "Redis" "NATS" "Qdrant" "Weaviate" "Prometheus" "Grafana" "Loki" "Trend_Monitor" "Agent_Router" "Memory_Policies" "Voice_Assistant_Runtime" "Thumbnail_Pipeline" "Upload_Automation" "Weights_and_Biases" "vLLM" "Llama_CPP" "Ray" "EnviroLLM" "Suno_API" "Udio_API" "MusicGen" "Riffusion" "ControlNet" "Music2P_Pipeline" "Hook_Detection" "BPM_Analyzer" "TikTok_Score" "Emotion_Tagging" "Docker" "Kubernetes" "K3s" "GitHub_API_Tooling" "Code_Sandbox" "VS_Code_Server" "Puppeteer" "OpenTelemetry" "Vault" "SQLite" "Postgres" "RabbitMQ" "EULLM" "AI_Powered_Law_Firms" "Lawfirm" "Tax_Law_Agent" "Risk_Agent" "Drafting_Agent" "PDF_Parser" "Neo4j" "Tax_Calculator" "Deadline_Checker" "Risk_Scoring" "GitHub_Research" "Repo_Comparison" "Fail2Ban_Analyzer" "Security_Workflow" "Browser_Tool" "Firecrawl" "Google_Analytics_API" "Meta_Ads_API" "TikTok_Ads_API" "File_System_Tool" "HubSpot" "Notion" "Airtable" "Buffer_API" "Zapier" "Make" "Ahrefs" "SEMrush" "ElevenLabs" "Zenbot_API" "Risk_Strategy_Analyzer" "Backtest_Workflow" "AnimateDiff" "SVD" "Runway_API" "Image_Upscaler_Pipeline")

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
}

mark_current_tool_installed() {
    [ -n "${CURRENT_TOOL_KEY:-}" ] || return 1
    append_unique_line "$TOOL_STATUS_FILE" "$CURRENT_TOOL_KEY"
}

mark_current_tool_removed() {
    [ -n "${CURRENT_TOOL_KEY:-}" ] || return 1
    remove_exact_line "$TOOL_STATUS_FILE" "$CURRENT_TOOL_KEY"
}
