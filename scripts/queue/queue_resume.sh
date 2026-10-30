#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --dry-run ]]; then
  echo "Plan: pausierte Jobs freigeben; keine Aenderung."
  exit 0
fi
[[ "$#" == 0 ]] || {
  echo "Fehler: Keine weiteren Argumente erwartet." >&2
  exit 64
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

queue_change_waiting_state paused queued
echo "Pausierte Jobs wurden wieder queued."
