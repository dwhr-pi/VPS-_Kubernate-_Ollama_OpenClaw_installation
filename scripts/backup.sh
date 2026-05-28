#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/scripts/operations/backup_run.sh" ]; then
  exec bash "$ROOT_DIR/scripts/operations/backup_run.sh" "$@"
fi
echo "Backup-Wrapper: siehe docs/BACKUP_RESTORE.md und docs/BACKUP_AND_RESTORE.md"
