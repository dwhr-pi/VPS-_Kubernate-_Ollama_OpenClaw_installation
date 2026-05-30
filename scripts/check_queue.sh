#!/usr/bin/env bash
set -euo pipefail

QUEUE_HOME="${QUEUE_HOME:-$HOME/.openclaw/job-queue}"
DB_FILE="${QUEUE_DB:-$QUEUE_HOME/queue.sqlite}"
CONFIG_FILE="$QUEUE_HOME/config.env"

echo "Queue-Check"
echo "Queue Home: $QUEUE_HOME"
echo "DB: $DB_FILE"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "WARN: Queue-Config fehlt: $CONFIG_FILE"
else
  echo "OK: Queue-Config vorhanden."
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "WARN: sqlite3 fehlt. Minimal-Queue benoetigt sqlite3."
  echo "INFO: Kein Fehler fuer documentation-first Setups. Installiere sqlite3 erst, wenn die Queue aktiv genutzt werden soll."
  exit 0
fi

if [[ ! -f "$DB_FILE" ]]; then
  echo "WARN: Queue-Datenbank fehlt. Initialisierung erfolgt beim ersten Submit."
  exit 0
fi

sqlite3 "$DB_FILE" "select status, count(*) from jobs group by status;" 2>/dev/null || {
  echo "WARN: Queue-Datenbank konnte nicht gelesen werden."
  exit 1
}
