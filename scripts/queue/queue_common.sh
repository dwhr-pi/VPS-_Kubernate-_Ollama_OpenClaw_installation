#!/usr/bin/env bash
set -euo pipefail

QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
QUEUE_DB="${QUEUE_DB:-$QUEUE_HOME/queue.sqlite}"
QUEUE_LOG_DIR="${QUEUE_LOG_DIR:-$QUEUE_HOME/logs}"
QUEUE_CONFIG="$QUEUE_HOME/config.env"

mkdir -p "$QUEUE_HOME" "$QUEUE_LOG_DIR"

if [[ ! -f "$QUEUE_CONFIG" ]]; then
  cat > "$QUEUE_CONFIG" <<'EOF'
MAX_PARALLEL_JOBS=1
MAX_LOAD_AVG=4
MIN_MEM_AVAILABLE_MB=1024
DEFAULT_TIMEOUT_SECONDS=3600
EOF
fi

# shellcheck disable=SC1090
source "$QUEUE_CONFIG"

require_sqlite() {
  if ! command -v sqlite3 >/dev/null 2>&1; then
    echo "Fehler: sqlite3 fehlt. Bitte sqlite3 installieren, bevor die Minimal-Queue genutzt wird." >&2
    exit 1
  fi
}

init_queue_db() {
  require_sqlite
  sqlite3 "$QUEUE_DB" <<'SQL'
create table if not exists jobs (
  id integer primary key autoincrement,
  command text not null,
  priority text not null default 'normal',
  status text not null default 'queued',
  attempts integer not null default 0,
  max_attempts integer not null default 1,
  timeout_seconds integer not null default 3600,
  log_path text,
  created_at text not null default current_timestamp,
  updated_at text not null default current_timestamp
);
SQL
}

resource_guard_ok() {
  local mem_mb load_int
  mem_mb="$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
  load_int="$(awk '{print int($1)}' /proc/loadavg 2>/dev/null || echo 0)"
  if [[ "$mem_mb" -lt "${MIN_MEM_AVAILABLE_MB:-1024}" ]]; then
    echo "WARN: Zu wenig freier RAM fuer neuen Queue-Job (${mem_mb} MB)."
    return 1
  fi
  if [[ "$load_int" -gt "${MAX_LOAD_AVG:-4}" ]]; then
    echo "WARN: Systemlast zu hoch fuer neuen Queue-Job (load ${load_int})."
    return 1
  fi
  return 0
}

