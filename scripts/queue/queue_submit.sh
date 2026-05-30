#!/usr/bin/env bash
set -euo pipefail

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
init_queue_db
escaped="${command_text//\'/\'\'}"
sqlite3 "$QUEUE_DB" "insert into jobs(command, priority, status, timeout_seconds) values('$escaped', '$priority', 'queued', ${DEFAULT_TIMEOUT_SECONDS:-3600});"
echo "Job eingereiht: priority=$priority"
