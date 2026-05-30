#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
QUEUE_DIR="${QUEUE_MANAGER_DIR:-$HOME/.openclaw_ultimate_user_data/queue}"

case "$MODE" in
  --dry-run|--apply|--status|--help|-h) ;;
  *)
    echo "Bitte --dry-run, --apply, --status oder --help verwenden." >&2
    exit 2
    ;;
esac

if [[ "$MODE" == "--help" || "$MODE" == "-h" ]]; then
  echo "Usage: bash scripts/tools/queue_manager_uninstall.sh [--dry-run|--apply|--status]"
  exit 0
fi

if [[ "$MODE" == "--status" ]]; then
  [[ -d "$QUEUE_DIR" ]] && echo "Queue-Ordner vorhanden: $QUEUE_DIR" || echo "Queue-Ordner fehlt: $QUEUE_DIR"
  exit 0
fi

if [[ "$MODE" == "--dry-run" ]]; then
  echo "DRY-RUN: wuerde Queue-Daten entfernen: $QUEUE_DIR"
  exit 0
fi

rm -rf "$QUEUE_DIR"
echo "Queue-Daten entfernt: $QUEUE_DIR"
