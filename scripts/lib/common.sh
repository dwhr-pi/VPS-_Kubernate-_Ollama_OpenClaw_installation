#!/usr/bin/env bash
set -euo pipefail

SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_LIB_DIR/../.." && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
USER_STATUS_DIR="${USER_WORKSPACE_DIR}/status"
USER_LOG_DIR="${USER_WORKSPACE_DIR}/logs"
USER_METRICS_DIR="${USER_WORKSPACE_DIR}/metrics_logs"
TOOL_STATUS_FILE="${USER_STATUS_DIR}/installed_tools.txt"
PROFILE_STATUS_FILE="${USER_STATUS_DIR}/installed_profiles.txt"
METRICS_HISTORY_FILE="${USER_METRICS_DIR}/operation_history.tsv"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

ensure_user_workspace() {
  mkdir -p "$USER_WORKSPACE_DIR" "$USER_STATUS_DIR" "$USER_LOG_DIR" "$USER_METRICS_DIR"
  touch "$TOOL_STATUS_FILE" "$PROFILE_STATUS_FILE"
  if [ ! -f "$METRICS_HISTORY_FILE" ]; then
    printf 'timestamp\toperation_id\toperation_title\tstatus\tduration_seconds\tfree_kb_before\tfree_kb_after\tdelta_kb\n' > "$METRICS_HISTORY_FILE"
  fi
}

log_info() { echo -e "${BLUE}$*${NC}"; }
log_warn() { echo -e "${YELLOW}$*${NC}"; }
log_error() { echo -e "${RED}$*${NC}" >&2; }
log_success() { echo -e "${GREEN}$*${NC}"; }

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
}

status_remove() {
  local file="$1"
  local value="$2"
  ensure_user_workspace
  grep -Fxv "$value" "$file" > "${file}.tmp" 2>/dev/null || true
  mv "${file}.tmp" "$file"
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
