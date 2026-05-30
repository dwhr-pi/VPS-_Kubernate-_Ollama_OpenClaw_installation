#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
QUEUE_DIR="${JOB_QUEUE_DIR:-$HOME/.openclaw_ultimate_user_data/job_queue}"

case "$MODE" in
  --dry-run|--apply|--status|--help|-h) ;;
  *) echo "Usage: bash scripts/tools/job_queue_uninstall.sh [--dry-run|--apply|--status]" >&2; exit 2 ;;
esac

if [[ "$MODE" == "--status" ]]; then
  [[ -d "$QUEUE_DIR" ]] && echo "Job Queue vorhanden: $QUEUE_DIR" || echo "Job Queue fehlt: $QUEUE_DIR"
  exit 0
fi

if [[ "$MODE" != "--apply" ]]; then
  echo "DRY-RUN: wuerde Job Queue entfernen: $QUEUE_DIR"
  exit 0
fi

rm -rf "$QUEUE_DIR"
echo "Job Queue entfernt: $QUEUE_DIR"
