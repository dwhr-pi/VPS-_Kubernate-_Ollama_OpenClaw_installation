#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --dry-run ]]; then
  echo "Plan: wartenden TSV-Job abbrechen; keine Aenderung."
  exit 0
fi
[[ "$#" == 1 && "$1" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || {
  echo "Nutzung: queue_cancel.sh <job_id>; nur wartende TSV-Jobs werden markiert." >&2
  exit 64
}

QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
QUEUE_FILE="${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}"
job_id="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_lock.sh
source "$SCRIPT_DIR/queue_lock.sh"

if [[ -z "$job_id" ]]; then
  echo "Nutzung: bash scripts/queue/queue_cancel.sh <job_id>"
  exit 1
fi

if [[ ! -f "$QUEUE_FILE" ]]; then
  echo "Keine Queue-Datei vorhanden."
  exit 0
fi

queue_lock_state
if ! awk -F '\t' -v id="$job_id" '$1==id && ($2=="queued" || $2=="paused") {found=1} END {exit !found}' "$QUEUE_FILE"; then
  echo "Kein wartender TSV-Job mit dieser ID; laufende Jobs werden nicht beendet." >&2
  exit 1
fi
tmp_file="$(mktemp "${QUEUE_FILE}.XXXXXX")"
awk -F '\t' -v OFS='\t' -v id="$job_id" '$1==id && ($2=="queued" || $2=="paused") {$2="cancelled"} {print}' "$QUEUE_FILE" >"$tmp_file"
mv "$tmp_file" "$QUEUE_FILE"
echo "Job als cancelled markiert: $job_id"
