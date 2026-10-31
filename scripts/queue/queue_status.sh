#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --dry-run ]]; then
  echo "Plan: vorhandenen Queue-Status lesen; keine Aenderung."
  exit 0
fi
[[ "$#" == 0 ]] || {
  echo "Fehler: Keine weiteren Argumente erwartet." >&2
  exit 64
}

# Read-only: do not source executable config or create a queue during inspection.
QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
QUEUE_DB="${QUEUE_DB:-$QUEUE_HOME/queue.sqlite}"

TSV_QUEUE_FILE="${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}"
if [[ -f "$TSV_QUEUE_FILE" ]]; then
  echo "TSV Queue: $TSV_QUEUE_FILE"
  awk -F '\t' 'BEGIN {printf "%-24s %-10s %-8s %-8s %s\n", "ID", "STATUS", "PRIO", "TRY", "EXIT"} {printf "%-24s %-10s %-8s %-8s %s\n", $1, $2, $3, $4, ($8==""?"-":$8)}' "$TSV_QUEUE_FILE"
  exit 0
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "Keine TSV-Queue gefunden und sqlite3 fehlt. Queue ist noch nicht initialisiert."
  exit 0
fi

if [[ ! -f "$QUEUE_DB" ]]; then
  echo "Queue noch nicht initialisiert."
  exit 0
fi
sqlite3 -readonly -header -column "$QUEUE_DB" "select id, priority, status, attempts, created_at, updated_at from jobs order by id desc limit 30;"
