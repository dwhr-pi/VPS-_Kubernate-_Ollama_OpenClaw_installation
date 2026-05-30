#!/usr/bin/env bash
set -euo pipefail

QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
QUEUE_FILE="${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}"
QUEUE_LOG_DIR="${QUEUE_LOG_DIR:-$QUEUE_HOME/logs}"
CONFIG_FILE="$QUEUE_HOME/config.env"
mkdir -p "$QUEUE_HOME" "$QUEUE_LOG_DIR"

if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$(dirname "${BASH_SOURCE[0]}")/queue_config.example" "$CONFIG_FILE"
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [[ ! -f "$QUEUE_FILE" ]]; then
  echo "Keine Queue-Datei vorhanden."
  exit 0
fi

mem_mb="$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
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

job_line="$(awk -F '\t' -v id="$selected_id" '$1==id {print; exit}' "$QUEUE_FILE")"
IFS=$'\t' read -r job_id _status priority attempts max_attempts timeout_seconds job_cmd <<< "$job_line"
attempts=$((attempts + 1))
log_path="$QUEUE_LOG_DIR/${job_id}.log"
tmp_file="$(mktemp)"

awk -F '\t' -v OFS='\t' -v id="$job_id" -v attempts="$attempts" '$1==id {$2="running"; $4=attempts} {print}' "$QUEUE_FILE" > "$tmp_file"
mv "$tmp_file" "$QUEUE_FILE"

echo "Starte Job $job_id: $job_cmd"
set +e
timeout "${timeout_seconds:-3600}" bash -lc "$job_cmd" > "$log_path" 2>&1
rc=$?
set -e

tmp_file="$(mktemp)"
if [[ "$rc" -eq 0 ]]; then
  awk -F '\t' -v OFS='\t' -v id="$job_id" '$1==id {$2="done"} {print}' "$QUEUE_FILE" > "$tmp_file"
  echo "Job $job_id erledigt. Log: $log_path"
else
  next_status="failed"
  if [[ "$attempts" -lt "${max_attempts:-1}" ]]; then
    next_status="queued"
  fi
  awk -F '\t' -v OFS='\t' -v id="$job_id" -v status="$next_status" '$1==id {$2=status} {print}' "$QUEUE_FILE" > "$tmp_file"
  echo "Job $job_id fehlgeschlagen (Exit $rc). Log: $log_path"
fi
mv "$tmp_file" "$QUEUE_FILE"
exit "$rc"

