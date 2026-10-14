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
rsync -a --delete "${USER_WORKSPACE_DIR}/" "${TARGET_DIR}/user_workspace/" --exclude "backups" --exclude "/env/" --exclude "/tools/paperless_ngx/" --exclude "/personnel_documents/" || true

# The encrypted vault lives under backups, which is intentionally excluded above.
VAULT_FILE="${USER_WORKSPACE_DIR}/backups/credentials/env-vault.age"
if [ -f "$VAULT_FILE" ] && [ ! -L "$VAULT_FILE" ]; then
  mkdir -m 700 -p "$TARGET_DIR/credentials"
  cp "$VAULT_FILE" "$TARGET_DIR/credentials/env-vault.age"
  chmod 600 "$TARGET_DIR/credentials/env-vault.age"
fi
log_warn "ENV-Tresor verschluesselt gesichert, sofern vorhanden. Generierte env/-Dateien sind ausgeschlossen; andere Workspace-Daten koennen weiterhin Secrets enthalten."
log_warn "Personalaktenpfade tools/paperless_ngx/ und personnel_documents/ sind NICHT gesichert: separaten konsistenten, verschluesselten Backup-/Restore-Prozess einrichten."

log_success "Backup abgeschlossen: $TARGET_DIR"
