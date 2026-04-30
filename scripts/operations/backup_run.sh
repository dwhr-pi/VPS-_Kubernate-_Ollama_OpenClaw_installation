#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

ensure_user_workspace
BACKUP_ROOT="${USER_WORKSPACE_DIR}/backups"
STAMP="$(date +%Y%m%d_%H%M%S)"
TARGET_DIR="${BACKUP_ROOT}/${STAMP}"
mkdir -p "$TARGET_DIR"

log_info "Erstelle lokales Backup unter: $TARGET_DIR"

rsync -a --delete "${REPO_ROOT}/" "${TARGET_DIR}/repo/" --exclude ".git" --exclude "node_modules" || true
rsync -a --delete "${USER_WORKSPACE_DIR}/" "${TARGET_DIR}/user_workspace/" --exclude "backups" || true

log_success "Backup abgeschlossen: $TARGET_DIR"
