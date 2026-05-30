#!/usr/bin/env bash
set -euo pipefail

QUEUE_DIR="${JOB_QUEUE_DIR:-$HOME/.openclaw_ultimate_user_data/job_queue}"
QUEUE_FILE="$QUEUE_DIR/jobs/jobs.jsonl"
COMMAND="${*:-}"

if [[ -z "$COMMAND" ]]; then
  echo "Usage: bash scripts/tools/job_queue_submit.sh \"<command>\"" >&2
  exit 2
fi

mkdir -p "$QUEUE_DIR/jobs" "$QUEUE_DIR/logs" "$QUEUE_DIR/state"
touch "$QUEUE_FILE"

JOB_ID="$(date +%Y%m%d%H%M%S)-$RANDOM"
CREATED_AT="$(date -Iseconds)"
ESCAPED_COMMAND="${COMMAND//\\/\\\\}"
ESCAPED_COMMAND="${ESCAPED_COMMAND//\"/\\\"}"
printf '{"id":"%s","status":"queued","retries":0,"created_at":"%s","command":"%s"}\n' "$JOB_ID" "$CREATED_AT" "$ESCAPED_COMMAND" >> "$QUEUE_FILE"
echo "$JOB_ID"
