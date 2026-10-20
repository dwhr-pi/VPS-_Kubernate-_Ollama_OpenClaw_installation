#!/usr/bin/env bash
set -euo pipefail

QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
QUEUE_DB="${QUEUE_DB:-$QUEUE_HOME/queue.sqlite}"
QUEUE_LOG_DIR="${QUEUE_LOG_DIR:-$QUEUE_HOME/logs}"
QUEUE_CONFIG="$QUEUE_HOME/config.env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_lock.sh
source "$SCRIPT_DIR/queue_lock.sh"
umask 077

mkdir -p "$QUEUE_HOME" "$QUEUE_LOG_DIR"

if [[ ! -f "$QUEUE_CONFIG" ]]; then
  cat > "$QUEUE_CONFIG" <<'EOF'
MAX_PARALLEL_JOBS=1
MAX_LOAD_AVG=4
MIN_MEM_AVAILABLE_MB=1024
MIN_DISK_FREE_MB=1024
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
  exit_code integer,
  created_at text not null default current_timestamp,
  updated_at text not null default current_timestamp
);
SQL
  if ! sqlite3 "$QUEUE_DB" "select name from pragma_table_info('jobs');" | grep -qx exit_code; then
    sqlite3 "$QUEUE_DB" "alter table jobs add column exit_code integer;"
  fi
}

queue_change_waiting_state() {
  local before="$1" after="$2" queue_file tmp_file
  queue_file="${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}"
  queue_lock_state
  if [[ -f "$queue_file" || "${QUEUE_MODE:-}" == tsv ]]; then
    [[ -f "$queue_file" ]] || { echo "Keine TSV-Queue vorhanden."; return 0; }
    tmp_file="$(mktemp "${queue_file}.XXXXXX")"
    awk -F '\t' -v OFS='\t' -v before="$before" -v after="$after" '$2==before {$2=after} {print}' "$queue_file" > "$tmp_file"
    mv "$tmp_file" "$queue_file"
  else
    init_queue_db
    sqlite3 "$QUEUE_DB" "update jobs set status='$after', updated_at=current_timestamp where status='$before';"
  fi
}

resource_guard_ok() {
  local mem_mb load_int disk_mb
  disk_mb="$(df -Pk "$QUEUE_HOME" | awk 'NR==2 {print int($4/1024)}')"
  if [[ ! "$disk_mb" =~ ^[0-9]+$ || "$disk_mb" -lt "${MIN_DISK_FREE_MB:-1024}" ]]; then
    echo "WARN: Zu wenig freier Disk-Speicher fuer neuen Queue-Job."
    return 1
  fi
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

