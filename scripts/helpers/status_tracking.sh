#!/bin/bash
# Gemeinsame Hilfsfunktionen für robuste Statusdateien und direkte Script-Aufrufe.

STATUS_HELPER_ROOT="${HOME}/.openclaw_ultimate_user_data"
PROFILE_STATUS_FILE="$STATUS_HELPER_ROOT/installed_profiles.txt"
TOOL_STATUS_FILE="$STATUS_HELPER_ROOT/installed_tools.txt"

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
