#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

init_queue_db
sqlite3 "$QUEUE_DB" "update jobs set status='queued', updated_at=current_timestamp where status='paused';"
echo "Pausierte Jobs wurden wieder queued."

