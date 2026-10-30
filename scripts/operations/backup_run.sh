#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

ensure_user_workspace
BACKUP_ROOT="${USER_WORKSPACE_DIR}/backups"
STAMP="$(date +%Y%m%d_%H%M%S)_$$"
TARGET_DIR="${BACKUP_ROOT}/${STAMP}"
mkdir -p "$BACKUP_ROOT"
mkdir -m 700 "$TARGET_DIR"

log_info "Erstelle lokales Backup unter: $TARGET_DIR"

python3 -I -B "$REPO_ROOT/scripts/operations/installation_inventory.py" export \
  --output "$TARGET_DIR/installation-inventory.json" --allow-workspace
if ! rsync -a --delete "${REPO_ROOT}/" "${TARGET_DIR}/repo/" --exclude ".git" --exclude "node_modules"; then
  log_error "Backup unvollstaendig: Repository-Kopie fehlgeschlagen. Teilbestand bleibt unter $TARGET_DIR."
  exit 1
fi
if ! rsync -a --delete "${USER_WORKSPACE_DIR}/" "${TARGET_DIR}/user_workspace/" --exclude "backups" --exclude "/env/" --exclude "/tools/paperless_ngx/" --exclude "/personnel_documents/"; then
  log_error "Backup unvollstaendig: Workspace-Kopie fehlgeschlagen. Teilbestand bleibt unter $TARGET_DIR."
  exit 1
fi

# The encrypted vault lives under backups, which is intentionally excluded above.
VAULT_FILE="${USER_WORKSPACE_DIR}/backups/credentials/env-vault.age"
if [ -f "$VAULT_FILE" ] && [ ! -L "$VAULT_FILE" ]; then
  mkdir -m 700 "$TARGET_DIR/credentials"
  cp "$VAULT_FILE" "$TARGET_DIR/credentials/env-vault.age"
  chmod 600 "$TARGET_DIR/credentials/env-vault.age"
fi
log_warn "ENV-Tresor verschluesselt gesichert, sofern vorhanden. Generierte env/-Dateien sind ausgeschlossen; andere Workspace-Daten koennen weiterhin Secrets enthalten."
log_warn "Personalaktenpfade tools/paperless_ngx/ und personnel_documents/ sind NICHT gesichert: separaten konsistenten, verschluesselten Backup-/Restore-Prozess einrichten."
log_warn "Programmliste: $TARGET_DIR/installation-inventory.md. Fuer Verlust von Workspace/Backup separat extern exportieren."
log_warn "ENV/API-Keys gesondert verschluesseln/exportieren: Optionen -> 21 -> 5; siehe docs/CREDENTIALS_BACKUP.md. Kein automatischer Mailversand."

log_success "Backup abgeschlossen: $TARGET_DIR"
