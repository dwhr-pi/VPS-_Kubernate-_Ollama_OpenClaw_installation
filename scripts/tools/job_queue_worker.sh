#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-status}"
ARG="${2:-}"
QUEUE_DIR="${JOB_QUEUE_DIR:-$HOME/.openclaw_ultimate_user_data/job_queue}"
QUEUE_FILE="$QUEUE_DIR/jobs/jobs.jsonl"
RUNNING_FILE="$QUEUE_DIR/state/worker.running"
CONFIG_FILE="$QUEUE_DIR/config.env"

mkdir -p "$QUEUE_DIR/jobs" "$QUEUE_DIR/logs" "$QUEUE_DIR/state"
touch "$QUEUE_FILE"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi
JOB_QUEUE_MAX_LOAD="${JOB_QUEUE_MAX_LOAD:-4}"
JOB_QUEUE_MIN_FREE_MB="${JOB_QUEUE_MIN_FREE_MB:-2048}"
JOB_QUEUE_TIMEOUT_SECONDS="${JOB_QUEUE_TIMEOUT_SECONDS:-3600}"
JOB_QUEUE_MAX_RETRIES="${JOB_QUEUE_MAX_RETRIES:-1}"

free_mb() {
  df -Pm "$QUEUE_DIR" | awk 'NR==2 {print int($4)}'
}

load_ok() {
  awk -v max="$JOB_QUEUE_MAX_LOAD" '{exit !($1 <= max)}' /proc/loadavg 2>/dev/null || return 0
}

disk_ok() {
  [[ "$(free_mb)" -ge "$JOB_QUEUE_MIN_FREE_MB" ]]
}

update_status() {
  local job_id="$1" status="$2"
  python3 - "$QUEUE_FILE" "$job_id" "$status" <<'PY'
import json, sys
path, job_id, status = sys.argv[1:4]
rows=[]
with open(path, encoding="utf-8") as fh:
    for line in fh:
        if not line.strip():
            continue
        item=json.loads(line)
        if item.get("id")==job_id:
            item["status"]=status
            item["updated_at"]=__import__("datetime").datetime.now().isoformat()
        rows.append(item)
with open(path, "w", encoding="utf-8") as fh:
    for item in rows:
        fh.write(json.dumps(item, ensure_ascii=False) + "\n")
PY
}

next_job() {
  python3 - "$QUEUE_FILE" <<'PY'
import json, sys
for line in open(sys.argv[1], encoding="utf-8"):
    if not line.strip():
        continue
    item=json.loads(line)
    if item.get("status")=="queued":
        print(json.dumps(item))
        break
PY
}

run_one() {
  local job_json job_id command log_file
  job_json="$(next_job)"
  [[ -z "$job_json" ]] && return 1
  job_id="$(printf '%s' "$job_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"
  command="$(printf '%s' "$job_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["command"])')"
  log_file="$QUEUE_DIR/logs/${job_id}.log"

  if ! load_ok || ! disk_ok; then
    echo "Ressourcenschutz aktiv: Load/Disk zu hoch. Job wird nicht gestartet."
    return 2
  fi

  update_status "$job_id" running
  echo "Starte Job $job_id: $command"
  if timeout "$JOB_QUEUE_TIMEOUT_SECONDS" bash -lc "$command" >"$log_file" 2>&1; then
    update_status "$job_id" done
    echo "Job fertig: $job_id"
  else
    update_status "$job_id" failed
    echo "Job fehlgeschlagen: $job_id (Log: $log_file)" >&2
    return 1
  fi
}

case "$ACTION" in
  start)
    echo "$$" > "$RUNNING_FILE"
    while true; do
      run_one || break
    done
    rm -f "$RUNNING_FILE"
    ;;
  stop)
    if [[ -f "$RUNNING_FILE" ]]; then
      kill "$(cat "$RUNNING_FILE")" 2>/dev/null || true
      rm -f "$RUNNING_FILE"
      echo "Worker gestoppt."
    else
      echo "Kein Worker aktiv."
    fi
    ;;
  status)
    [[ -f "$RUNNING_FILE" ]] && echo "Worker laeuft: $(cat "$RUNNING_FILE")" || echo "Worker laeuft nicht."
    ;;
  logs)
    [[ -n "$ARG" ]] || { echo "Usage: job_queue_worker.sh logs <job_id>" >&2; exit 2; }
    cat "$QUEUE_DIR/logs/${ARG}.log"
    ;;
  *)
    echo "Usage: job_queue_worker.sh start|stop|status|logs <job_id>" >&2
    exit 2
    ;;
esac
