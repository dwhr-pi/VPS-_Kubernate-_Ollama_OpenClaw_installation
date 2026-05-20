#!/usr/bin/env bash
set -euo pipefail

SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_LIB_DIR/../.." && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
USER_STATUS_DIR="${USER_WORKSPACE_DIR}/status"
USER_LOG_DIR="${USER_WORKSPACE_DIR}/logs"
USER_METRICS_DIR="${USER_WORKSPACE_DIR}/metrics_logs"
CUSTOM_SOURCE_REPOS_DIR="${USER_WORKSPACE_DIR}/custom_sources"
CUSTOM_SOURCES_FILE="${USER_WORKSPACE_DIR}/custom_sources.conf"
CUSTOM_OLLAMA_BUILDS_FILE="${USER_WORKSPACE_DIR}/custom_ollama_builds.conf"
TOOL_STATUS_FILE="${USER_STATUS_DIR}/installed_tools.txt"
PROFILE_STATUS_FILE="${USER_STATUS_DIR}/installed_profiles.txt"
LEGACY_TOOL_STATUS_FILE="${USER_WORKSPACE_DIR}/installed_tools.txt"
LEGACY_PROFILE_STATUS_FILE="${USER_WORKSPACE_DIR}/installed_profiles.txt"
METRICS_HISTORY_FILE="${USER_METRICS_DIR}/operation_history.tsv"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

dialog() {
  local arg
  local has_cancel_label=0

  for arg in "$@"; do
    if [ "$arg" = "--cancel-label" ]; then
      has_cancel_label=1
      break
    fi
  done

  if [ "$has_cancel_label" -eq 1 ]; then
    command dialog "$@"
  else
    command dialog --cancel-label "${TXT_BACK_LABEL:-Zurueck}" "$@"
  fi
}

ensure_user_workspace() {
  mkdir -p "$USER_WORKSPACE_DIR" "$USER_STATUS_DIR" "$USER_LOG_DIR" "$USER_METRICS_DIR" "$CUSTOM_SOURCE_REPOS_DIR"
  touch "$TOOL_STATUS_FILE" "$PROFILE_STATUS_FILE" "$LEGACY_TOOL_STATUS_FILE" "$LEGACY_PROFILE_STATUS_FILE"

  if [ ! -s "$LEGACY_TOOL_STATUS_FILE" ] && [ -s "$TOOL_STATUS_FILE" ]; then
    cp "$TOOL_STATUS_FILE" "$LEGACY_TOOL_STATUS_FILE"
  elif [ ! -s "$TOOL_STATUS_FILE" ] && [ -s "$LEGACY_TOOL_STATUS_FILE" ]; then
    cp "$LEGACY_TOOL_STATUS_FILE" "$TOOL_STATUS_FILE"
  fi

  if [ ! -s "$LEGACY_PROFILE_STATUS_FILE" ] && [ -s "$PROFILE_STATUS_FILE" ]; then
    cp "$PROFILE_STATUS_FILE" "$LEGACY_PROFILE_STATUS_FILE"
  elif [ ! -s "$PROFILE_STATUS_FILE" ] && [ -s "$LEGACY_PROFILE_STATUS_FILE" ]; then
    cp "$LEGACY_PROFILE_STATUS_FILE" "$PROFILE_STATUS_FILE"
  fi

  if [ ! -f "$METRICS_HISTORY_FILE" ]; then
    printf 'timestamp\toperation_id\toperation_title\tstatus\tduration_seconds\tfree_kb_before\tfree_kb_after\tdelta_kb\n' > "$METRICS_HISTORY_FILE"
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
# Standard Huginn: https://github.com/huginn/huginn.git
# Empfohlenes Standardprofil: stable-release
# Empfohlener Standard-Ref: v2022.08.18
CUSTOM_REPO_HUGINN_URL=""
CUSTOM_REPO_HUGINN_REF=""
CUSTOM_REPO_HUGINN_PROFILE="stable-release"
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
}

log_info() { echo -e "${BLUE}$*${NC}"; }
log_warn() { echo -e "${YELLOW}$*${NC}"; }
log_error() { echo -e "${RED}$*${NC}" >&2; }
log_success() { echo -e "${GREEN}$*${NC}"; }

run_with_retry() {
  local attempts="${1:?attempt count required}"
  local delay_seconds="${2:?delay seconds required}"
  shift 2

  local attempt=1
  local exit_code=0
  while [ "$attempt" -le "$attempts" ]; do
    if "$@"; then
      return 0
    else
      exit_code=$?
    fi
    if [ "$attempt" -ge "$attempts" ]; then
      break
    fi
    log_warn "Befehl fehlgeschlagen (Versuch ${attempt}/${attempts}): $*"
    log_warn "Warte ${delay_seconds}s und versuche es erneut..."
    sleep "$delay_seconds"
    attempt=$((attempt + 1))
  done

  return "$exit_code"
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Fehler: Befehl '$cmd' fehlt."
    exit 1
  fi
}

status_add() {
  local file="$1"
  local value="$2"
  ensure_user_workspace
  grep -Fxv "$value" "$file" > "${file}.tmp" 2>/dev/null || true
  mv "${file}.tmp" "$file"
  printf '%s\n' "$value" >> "$file"

  case "$file" in
    "$TOOL_STATUS_FILE")
      grep -Fxv "$value" "$LEGACY_TOOL_STATUS_FILE" > "${LEGACY_TOOL_STATUS_FILE}.tmp" 2>/dev/null || true
      mv "${LEGACY_TOOL_STATUS_FILE}.tmp" "$LEGACY_TOOL_STATUS_FILE"
      printf '%s\n' "$value" >> "$LEGACY_TOOL_STATUS_FILE"
      ;;
    "$PROFILE_STATUS_FILE")
      grep -Fxv "$value" "$LEGACY_PROFILE_STATUS_FILE" > "${LEGACY_PROFILE_STATUS_FILE}.tmp" 2>/dev/null || true
      mv "${LEGACY_PROFILE_STATUS_FILE}.tmp" "$LEGACY_PROFILE_STATUS_FILE"
      printf '%s\n' "$value" >> "$LEGACY_PROFILE_STATUS_FILE"
      ;;
  esac
}

status_remove() {
  local file="$1"
  local value="$2"
  ensure_user_workspace
  grep -Fxv "$value" "$file" > "${file}.tmp" 2>/dev/null || true
  mv "${file}.tmp" "$file"

  case "$file" in
    "$TOOL_STATUS_FILE")
      grep -Fxv "$value" "$LEGACY_TOOL_STATUS_FILE" > "${LEGACY_TOOL_STATUS_FILE}.tmp" 2>/dev/null || true
      mv "${LEGACY_TOOL_STATUS_FILE}.tmp" "$LEGACY_TOOL_STATUS_FILE"
      ;;
    "$PROFILE_STATUS_FILE")
      grep -Fxv "$value" "$LEGACY_PROFILE_STATUS_FILE" > "${LEGACY_PROFILE_STATUS_FILE}.tmp" 2>/dev/null || true
      mv "${LEGACY_PROFILE_STATUS_FILE}.tmp" "$LEGACY_PROFILE_STATUS_FILE"
      ;;
  esac
}

mark_tool_installed() { status_add "$TOOL_STATUS_FILE" "$1"; }
mark_tool_removed() { status_remove "$TOOL_STATUS_FILE" "$1"; }
mark_profile_installed() { status_add "$PROFILE_STATUS_FILE" "$1"; }
mark_profile_removed() { status_remove "$PROFILE_STATUS_FILE" "$1"; }

snapshot_disk_mb() {
  df -Pm "${1:-/}" | awk 'NR==2 {print $4}'
}

snapshot_disk_kb() {
  df -Pk "${1:-/}" | awk 'NR==2 {print $4}'
}

snapshot_ram_mb() {
  awk '/MemTotal/ {printf "%d\n", $2/1024}' /proc/meminfo
}

snapshot_cpu_cores() {
  getconf _NPROCESSORS_ONLN 2>/dev/null || echo "1"
}

snapshot_gpu_summary() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || true
  elif command -v rocminfo >/dev/null 2>&1; then
    rocminfo 2>/dev/null | grep -E 'Marketing Name|Compute Unit' || true
  else
    echo "Keine dedizierte GPU erkannt oder kein Tool vorhanden."
  fi
}

append_log() {
  local name="$1"
  shift
  ensure_user_workspace
  local logfile="${USER_LOG_DIR}/${name}.log"
  "$@" 2>&1 | tee -a "$logfile"
}

begin_measurement() {
  ensure_user_workspace
  export CURRENT_OPERATION_ID="$1"
  export CURRENT_OPERATION_TITLE="$2"
  export CURRENT_OPERATION_START_TS="$(date +%s)"
  export CURRENT_OPERATION_FREE_KB_BEFORE="$(snapshot_disk_kb /)"
}

end_measurement() {
  ensure_user_workspace
  local status="$1"
  local end_ts duration free_after delta timestamp
  end_ts="$(date +%s)"
  free_after="$(snapshot_disk_kb /)"
  duration=$((end_ts - ${CURRENT_OPERATION_START_TS:-$end_ts}))
  delta=$(( ${CURRENT_OPERATION_FREE_KB_BEFORE:-$free_after} - free_after ))
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$timestamp" \
    "${CURRENT_OPERATION_ID:-unknown}" \
    "${CURRENT_OPERATION_TITLE:-Unbekannte Operation}" \
    "$status" \
    "$duration" \
    "${CURRENT_OPERATION_FREE_KB_BEFORE:-$free_after}" \
    "$free_after" \
    "$delta" >> "$METRICS_HISTORY_FILE"
}

run_measured() {
  local operation_id="$1"
  local operation_title="$2"
  shift 2
  begin_measurement "$operation_id" "$operation_title"
  if "$@"; then
    end_measurement "success"
    return 0
  else
    end_measurement "failed"
    return 1
  fi
}

confirm_heavy_install() {
  local label="$1"
  if [ -t 0 ]; then
    printf '%b' "${YELLOW}Warnung: ${label} ist ein schweres/optionales Tool. Installation wirklich starten? (j/N): ${NC}"
    read -r answer
    case "$answer" in
      j|J|y|Y|yes|YES) return 0 ;;
      *) log_warn "${label} wurde vom Nutzer abgebrochen."; return 1 ;;
    esac
  fi
  return 0
}

load_custom_sources_config() {
  ensure_user_workspace
  # shellcheck source=/dev/null
  source "$CUSTOM_SOURCES_FILE"
}

get_custom_repo_url() {
  local key="$1"
  local default_url="$2"
  local var_name="CUSTOM_REPO_${key}_URL"
  local value=""

  load_custom_sources_config
  value="${!var_name:-}"
  if [ -n "$value" ]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$default_url"
  fi
}

get_custom_repo_ref() {
  local key="$1"
  local default_ref="$2"
  local var_name="CUSTOM_REPO_${key}_REF"
  local value=""

  load_custom_sources_config
  value="${!var_name:-}"
  if [ -n "$value" ]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$default_ref"
  fi
}

get_custom_repo_profile() {
  local key="$1"
  local default_profile="$2"
  local var_name="CUSTOM_REPO_${key}_PROFILE"
  local value=""

  load_custom_sources_config
  value="${!var_name:-}"
  if [ -n "$value" ]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$default_profile"
  fi
}
