#!/usr/bin/env bash
set -euo pipefail

QUEUE_DIR="${JOB_QUEUE_DIR:-$HOME/.openclaw_ultimate_user_data/job_queue}"
QUEUE_FILE="$QUEUE_DIR/jobs/jobs.jsonl"

if [[ ! -f "$QUEUE_FILE" ]]; then
  echo "Keine Queue gefunden: $QUEUE_FILE"
  exit 0
fi

echo "Job Queue: $QUEUE_FILE"
tail -n 50 "$QUEUE_FILE"
