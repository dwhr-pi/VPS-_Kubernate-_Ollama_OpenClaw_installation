#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --dry-run ]]; then
  echo "Plan: einen Queue-Auftrag einreihen; keine Aenderung."
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

priority="normal"
if [[ "${1:-}" == "--priority" ]]; then
  priority="${2:-normal}"
  shift 2
fi

if [[ "${1:-}" == "--" ]]; then
  shift
fi

if [[ "$#" -lt 1 ]]; then
  echo "Nutzung: bash scripts/queue/queue_submit.sh [--priority low|normal|high] -- <command>"
  exit 1
fi

command_text="$*"
if [[ "$command_text" == *$'\n'* || "$command_text" == *$'\r'* || "$command_text" == *$'\t'* ]]; then
  echo "Fehler: Queue-Kommandos muessen einzeilig sein." >&2
  exit 1
fi
case "$priority" in
  low|normal|high) ;;
  *) echo "Fehler: Prioritaet muss low, normal oder high sein." >&2; exit 1 ;;
esac
if [[ ! "${DEFAULT_TIMEOUT_SECONDS:-3600}" =~ ^[1-9][0-9]{0,5}$ ]]; then
  echo "Fehler: Ungueltiger Queue-Timeout." >&2
  exit 1
fi
if [[ "${QUEUE_MODE:-}" == tsv || -f "${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}" ]]; then
  exec bash "$SCRIPT_DIR/queue_add.sh" --priority "$priority" -- "$command_text"
fi
queue_lock_state
init_queue_db
escaped="${command_text//\'/\'\'}"
sqlite3 "$QUEUE_DB" "insert into jobs(command, priority, status, timeout_seconds) values('$escaped', '$priority', 'queued', ${DEFAULT_TIMEOUT_SECONDS:-3600});"
echo "Job eingereiht: priority=$priority"
