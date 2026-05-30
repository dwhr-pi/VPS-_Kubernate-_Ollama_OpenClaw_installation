#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

if [[ "${QUEUE_MODE:-}" == "tsv" || -f "${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}" ]]; then
  "$SCRIPT_DIR/queue_run_next.sh"
  exit $?
fi

init_queue_db

if ! resource_guard_ok; then
  exit 0
fi

job_row="$(sqlite3 -separator '|' "$QUEUE_DB" "select id, command, timeout_seconds from jobs where status='queued' order by case priority when 'high' then 0 when 'normal' then 1 else 2 end, id limit 1;")"
if [[ -z "$job_row" ]]; then
  echo "Keine queued Jobs."
  exit 0
fi

job_id="${job_row%%|*}"
rest="${job_row#*|}"
job_cmd="${rest%|*}"
timeout_seconds="${rest##*|}"
log_path="$QUEUE_LOG_DIR/job_${job_id}.log"

sqlite3 "$QUEUE_DB" "update jobs set status='running', attempts=attempts+1, log_path='$log_path', updated_at=current_timestamp where id=$job_id;"

echo "Starte Job $job_id: $job_cmd"
set +e
timeout "${timeout_seconds:-3600}" bash -lc "$job_cmd" >"$log_path" 2>&1
rc=$?
set -e

if [[ "$rc" -eq 0 ]]; then
  sqlite3 "$QUEUE_DB" "update jobs set status='done', updated_at=current_timestamp where id=$job_id;"
  echo "Job $job_id erledigt. Log: $log_path"
else
  sqlite3 "$QUEUE_DB" "update jobs set status='failed', updated_at=current_timestamp where id=$job_id;"
  echo "Job $job_id fehlgeschlagen (Exit $rc). Log: $log_path"
  exit "$rc"
fi
