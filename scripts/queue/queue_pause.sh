#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

init_queue_db
sqlite3 "$QUEUE_DB" "update jobs set status='paused', updated_at=current_timestamp where status='queued';"
echo "Alle queued Jobs wurden pausiert."

