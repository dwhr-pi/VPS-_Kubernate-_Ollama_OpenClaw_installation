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

priority="normal"
if [[ "${1:-}" == "--priority" ]]; then
  priority="${2:-normal}"
  shift 2
fi
if [[ "${1:-}" == "--" ]]; then
  shift
fi
if [[ "$#" -lt 1 ]]; then
  echo "Nutzung: bash scripts/queue/queue_add.sh [--priority low|normal|high] -- <command>"
  exit 1
fi

case "$priority" in
  low|normal|high) ;;
  *) echo "Fehler: Prioritaet muss low, normal oder high sein."; exit 1 ;;
esac

touch "$QUEUE_FILE"
job_id="$(date +%Y%m%d%H%M%S)-$$"
command_text="$*"
safe_command="${command_text//$'\t'/ }"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$job_id" "queued" "$priority" "0" "1" "${DEFAULT_TIMEOUT_SECONDS:-3600}" "$safe_command" >> "$QUEUE_FILE"
echo "Job eingereiht: $job_id ($priority)"

