#!/usr/bin/env bash
# Worker and metadata locks have different lifetimes: submit must work during a job.
queue_lock_open() {
  command -v flock >/dev/null 2>&1 || {
    echo "Fehler: flock (util-linux) fehlt; kein ungesicherter Queue-Zugriff." >&2
    return 1
  }
  [[ "$QUEUE_HOME" == /* && "$QUEUE_HOME" != / && ! -L "$QUEUE_HOME" ]] || return 1
  umask 077
  mkdir -p "$QUEUE_HOME"
}

queue_lock_worker() {
  queue_lock_open || return 1
  [[ ! -L "$QUEUE_HOME/worker.lock" ]] || return 1
  exec 9>"$QUEUE_HOME/worker.lock"
  if ! flock -n 9; then
    echo "Queue-Worker bereits aktiv; kein zweiter Job gestartet."
    return 75
  fi
}

queue_lock_state() {
  queue_lock_open || return 1
  [[ ! -L "$QUEUE_HOME/state.lock" ]] || return 1
  exec 8>"$QUEUE_HOME/state.lock"
  flock -x -w 10 8
}

queue_unlock_state() {
  flock -u 8
  exec 8>&-
}
