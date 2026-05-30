#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
QUEUE_DIR="${JOB_QUEUE_DIR:-$HOME/.openclaw_ultimate_user_data/job_queue}"

case "$MODE" in
  --dry-run|--prepare|--status|--help|-h) ;;
  *) echo "Usage: bash scripts/tools/job_queue_install.sh [--dry-run|--prepare|--status]" >&2; exit 2 ;;
esac

if [[ "$MODE" == "--help" || "$MODE" == "-h" ]]; then
  echo "Usage: bash scripts/tools/job_queue_install.sh [--dry-run|--prepare|--status]"
  exit 0
fi

if [[ "$MODE" == "--status" ]]; then
  [[ -d "$QUEUE_DIR" ]] && echo "Job Queue vorhanden: $QUEUE_DIR" || echo "Job Queue fehlt: $QUEUE_DIR"
  exit 0
fi

if [[ "$MODE" == "--dry-run" ]]; then
  echo "DRY-RUN: wuerde lokale Job Queue vorbereiten: $QUEUE_DIR"
  exit 0
fi

mkdir -p "$QUEUE_DIR/jobs" "$QUEUE_DIR/logs" "$QUEUE_DIR/state"
cat > "$QUEUE_DIR/config.env" <<'EOF'
JOB_QUEUE_MAX_PARALLEL=1
JOB_QUEUE_MAX_LOAD=4
JOB_QUEUE_MIN_FREE_MB=2048
JOB_QUEUE_TIMEOUT_SECONDS=3600
JOB_QUEUE_MAX_RETRIES=1
EOF
touch "$QUEUE_DIR/jobs/jobs.jsonl"
echo "Job Queue vorbereitet: $QUEUE_DIR"
