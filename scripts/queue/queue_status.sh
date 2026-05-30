#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

TSV_QUEUE_FILE="${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}"
if [[ -f "$TSV_QUEUE_FILE" ]]; then
  echo "TSV Queue: $TSV_QUEUE_FILE"
  awk -F '\t' 'BEGIN {printf "%-24s %-10s %-8s %-8s %s\n", "ID", "STATUS", "PRIO", "TRY", "COMMAND"} {printf "%-24s %-10s %-8s %-8s %s\n", $1, $2, $3, $4, $7}' "$TSV_QUEUE_FILE"
  exit 0
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "Keine TSV-Queue gefunden und sqlite3 fehlt. Queue ist noch nicht initialisiert."
  exit 0
fi

init_queue_db
sqlite3 -header -column "$QUEUE_DB" "select id, priority, status, attempts, created_at, updated_at from jobs order by id desc limit 30;"
