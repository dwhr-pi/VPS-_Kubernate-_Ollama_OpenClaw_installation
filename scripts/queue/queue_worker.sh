#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --dry-run ]]; then
  echo "Plan: hoechstens einen freigegebenen Queue-Job ausfuehren; keine Aenderung."
  exit 0
fi
[[ "$#" == 0 ]] || { echo "Fehler: Worker erwartet keine Argumente ausser --dry-run." >&2; exit 64; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=queue_common.sh
source "$SCRIPT_DIR/queue_common.sh"

if [[ "${QUEUE_MODE:-}" == "tsv" || -f "${QUEUE_FILE:-$QUEUE_HOME/jobs.tsv}" ]]; then
  exec bash "$SCRIPT_DIR/queue_run_next.sh"
fi

queue_lock_worker || { rc=$?; [[ "$rc" == 75 ]] && exit 0; exit "$rc"; }
if [[ "${MAX_PARALLEL_JOBS:-1}" != 1 ]]; then
  echo "Fehler: Dieser Minimal-Worker unterstuetzt MAX_PARALLEL_JOBS=1." >&2
  exit 1
fi
queue_lock_state
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
if [[ ! "$job_id" =~ ^[1-9][0-9]*$ || ! "$timeout_seconds" =~ ^[1-9][0-9]{0,5}$ ]]; then
  echo "Fehler: Ungueltige Queue-Metadaten; kein Job gestartet." >&2
  exit 1
fi
log_path="$QUEUE_LOG_DIR/job_${job_id}.log"
log_sql="${log_path//\'/\'\'}"

sqlite3 "$QUEUE_DB" "update jobs set status='running', attempts=attempts+1, log_path='$log_sql', exit_code=null, updated_at=current_timestamp where id=$job_id;"
queue_unlock_state

echo "Starte Job $job_id."
set +e
timeout --kill-after=10 "${timeout_seconds:-3600}" bash -lc "$job_cmd" >"$log_path" 2>&1 8>&- 9>&-
rc=$?
set -e
queue_lock_state

if [[ "$rc" -eq 0 ]]; then
  sqlite3 "$QUEUE_DB" "update jobs set status='done', exit_code=$rc, updated_at=current_timestamp where id=$job_id;"
  echo "Job $job_id erledigt. Log: $log_path"
else
  sqlite3 "$QUEUE_DB" "update jobs set status='failed', exit_code=$rc, updated_at=current_timestamp where id=$job_id;"
  echo "Job $job_id fehlgeschlagen (Exit $rc). Log: $log_path"
  exit "$rc"
fi
