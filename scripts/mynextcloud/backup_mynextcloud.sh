#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/mynextcloud/backup_mynextcloud.sh --data-dir DIR --backup-dir DIR [--db-name NAME --db-user USER] [--apply]

Dry-run by default. With --apply it creates a timestamped tar archive of the data dir.
If --db-name is provided and pg_dump exists, it also writes a database dump.
USAGE
}

DATA_DIR=""
BACKUP_DIR=""
DB_NAME=""
DB_USER=""
APPLY=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --data-dir) DATA_DIR="${2:-}"; shift 2 ;;
    --backup-dir) BACKUP_DIR="${2:-}"; shift 2 ;;
    --db-name) DB_NAME="${2:-}"; shift 2 ;;
    --db-user) DB_USER="${2:-}"; shift 2 ;;
    --apply) APPLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unbekannte Option: $1" >&2; usage; exit 1 ;;
  esac
done

[ -n "$DATA_DIR" ] || { echo "Fehler: --data-dir fehlt" >&2; exit 1; }
[ -n "$BACKUP_DIR" ] || { echo "Fehler: --backup-dir fehlt" >&2; exit 1; }

STAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE="$BACKUP_DIR/mynextcloud_data_$STAMP.tar.gz"
DUMP="$BACKUP_DIR/mynextcloud_db_$STAMP.sql"

echo "Datenquelle: $DATA_DIR"
echo "Backup-Ziel: $BACKUP_DIR"
echo "Archiv: $ARCHIVE"
[ -n "$DB_NAME" ] && echo "DB-Dump: $DUMP"

if [ "$APPLY" -ne 1 ]; then
  echo "DRY-RUN: Fuer echtes Backup --apply setzen."
  exit 0
fi

mkdir -p "$BACKUP_DIR"
tar -czf "$ARCHIVE" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")"
if [ -n "$DB_NAME" ] && command -v pg_dump >/dev/null 2>&1; then
  if [ -n "$DB_USER" ]; then
    pg_dump -U "$DB_USER" "$DB_NAME" > "$DUMP"
  else
    pg_dump "$DB_NAME" > "$DUMP"
  fi
fi
echo "Backup abgeschlossen."
