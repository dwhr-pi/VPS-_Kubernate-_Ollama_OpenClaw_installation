#!/usr/bin/env bash
set -euo pipefail

QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
QUEUE_FILE="${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}"
job_id="${1:-}"

if [[ -z "$job_id" ]]; then
  echo "Nutzung: bash scripts/queue/queue_cancel.sh <job_id>"
  exit 1
fi

if [[ ! -f "$QUEUE_FILE" ]]; then
  echo "Keine Queue-Datei vorhanden."
  exit 0
fi

tmp_file="$(mktemp)"
awk -F '\t' -v OFS='\t' -v id="$job_id" '$1==id && ($2=="queued" || $2=="paused") {$2="cancelled"} {print}' "$QUEUE_FILE" > "$tmp_file"
mv "$tmp_file" "$QUEUE_FILE"
echo "Job als cancelled markiert: $job_id"

