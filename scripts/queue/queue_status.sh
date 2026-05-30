#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

init_queue_db
sqlite3 -header -column "$QUEUE_DB" "select id, priority, status, attempts, created_at, updated_at from jobs order by id desc limit 30;"

