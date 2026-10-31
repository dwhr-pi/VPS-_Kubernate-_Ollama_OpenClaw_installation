#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --dry-run ]]; then
  echo "Plan: hoechstens einen TSV-Job ausfuehren; keine Aenderung."
  exit 0
fi
[[ "$#" == 0 ]] || {
  echo "Fehler: Worker erwartet keine Argumente ausser --dry-run." >&2
  exit 64
}

QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
QUEUE_FILE="${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}"
QUEUE_LOG_DIR="${QUEUE_LOG_DIR:-$QUEUE_HOME/logs}"
CONFIG_FILE="$QUEUE_HOME/config.env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_lock.sh
source "$SCRIPT_DIR/queue_lock.sh"
queue_lock_worker || {
  rc=$?
  [[ "$rc" == 75 ]] && exit 0
  exit "$rc"
}
mkdir -p "$QUEUE_HOME" "$QUEUE_LOG_DIR"

if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$(dirname "${BASH_SOURCE[0]}")/queue_config.example" "$CONFIG_FILE"
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [[ "${MAX_PARALLEL_JOBS:-1}" != 1 ]]; then
  echo "Fehler: Dieser Minimal-Worker unterstuetzt MAX_PARALLEL_JOBS=1." >&2
  exit 1
fi

if [[ ! -f "$QUEUE_FILE" ]]; then
  echo "Keine Queue-Datei vorhanden."
  exit 0
fi

mem_mb="$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
disk_mb="$(df -Pk "$QUEUE_HOME" | awk 'NR==2 {print int($4/1024)}')"
if [[ ! "$disk_mb" =~ ^[0-9]+$ || "$disk_mb" -lt "${MIN_DISK_FREE_MB:-1024}" ]]; then
  echo "WARN: Zu wenig freier Disk-Speicher fuer neuen Queue-Job."
  exit 0
fi
load_int="$(awk '{print int($1)}' /proc/loadavg 2>/dev/null || echo 0)"
if [[ "$mem_mb" -lt "${MIN_MEM_AVAILABLE_MB:-1024}" ]]; then
  echo "WARN: Zu wenig RAM fuer neuen Job (${mem_mb} MB)."
  exit 0
fi
if [[ "$load_int" -gt "${MAX_LOAD_AVG:-4}" ]]; then
  echo "WARN: Load zu hoch fuer neuen Job (${load_int})."
  exit 0
fi

selected_id="$(awk -F '\t' '$2=="queued" {rank=($3=="high"?0:($3=="normal"?1:2)); print rank "\t" NR "\t" $1}' "$QUEUE_FILE" | sort -n -k1,1 -k2,2 | awk -F '\t' 'NR==1 {print $3}')"
if [[ -z "$selected_id" ]]; then
  echo "Keine queued Jobs."
  exit 0
fi

queue_lock_state
# Re-select while locked: cancellation/pause may have changed the earlier snapshot.
selected_id="$(awk -F '\t' '$2=="queued" {rank=($3=="high"?0:($3=="normal"?1:2)); print rank "\t" NR "\t" $1}' "$QUEUE_FILE" | sort -n -k1,1 -k2,2 | awk -F '\t' 'NR==1 {print $3}')"
[[ -n "$selected_id" ]] || exit 0
job_line="$(awk -F '\t' -v id="$selected_id" '$1==id {print; exit}' "$QUEUE_FILE")"
IFS=$'\t' read -r job_id _status _priority attempts max_attempts timeout_seconds job_cmd _exit_code <<<"$job_line"
if [[ ! "$job_id" =~ ^[A-Za-z0-9_-]+$ || ! "$attempts" =~ ^[0-9]{1,6}$ ||
  ! "$max_attempts" =~ ^[1-9][0-9]{0,5}$ || ! "$timeout_seconds" =~ ^[1-9][0-9]{0,5}$ ]]; then
  echo "Fehler: Ungueltige Queue-Metadaten; kein Job gestartet." >&2
  exit 1
fi
attempts=$((attempts + 1))
log_path="$QUEUE_LOG_DIR/${job_id}.log"
tmp_file="$(mktemp "${QUEUE_FILE}.XXXXXX")"

awk -F '\t' -v OFS='\t' -v id="$job_id" -v attempts="$attempts" '$1==id {$2="running"; $4=attempts} {print}' "$QUEUE_FILE" >"$tmp_file"
mv "$tmp_file" "$QUEUE_FILE"
queue_unlock_state

echo "Starte Job $job_id."
set +e
timeout --kill-after=10 "${timeout_seconds:-3600}" bash -lc "$job_cmd" >"$log_path" 2>&1 8>&- 9>&-
rc=$?
set -e

queue_lock_state
tmp_file="$(mktemp "${QUEUE_FILE}.XXXXXX")"
if [[ "$rc" -eq 0 ]]; then
  awk -F '\t' -v OFS='\t' -v id="$job_id" '$1==id {$2="done"; $8=0} {print}' "$QUEUE_FILE" >"$tmp_file"
  echo "Job $job_id erledigt. Log: $log_path"
else
  next_status="failed"
  if [[ "$attempts" -lt "${max_attempts:-1}" ]]; then
    next_status="queued"
  fi
  awk -F '\t' -v OFS='\t' -v id="$job_id" -v status="$next_status" -v rc="$rc" '$1==id {$2=status; $8=rc} {print}' "$QUEUE_FILE" >"$tmp_file"
  echo "Job $job_id fehlgeschlagen (Exit $rc). Log: $log_path"
fi
mv "$tmp_file" "$QUEUE_FILE"
exit "$rc"
