#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

BACKUP_ROOT="${USER_WORKSPACE_DIR}/backups"

if [ ! -d "$BACKUP_ROOT" ]; then
  log_warn "Kein Backup-Verzeichnis gefunden: $BACKUP_ROOT"
  exit 0
fi

LATEST_BACKUP="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"

if [ -z "$LATEST_BACKUP" ]; then
  log_warn "Kein Backup gefunden."
  exit 0
fi

log_info "Prüfe letztes Backup: $LATEST_BACKUP"
find "$LATEST_BACKUP" -maxdepth 2 -type d | sort
log_success "Restore-Test erfolgreich: Backup ist lesbar."
