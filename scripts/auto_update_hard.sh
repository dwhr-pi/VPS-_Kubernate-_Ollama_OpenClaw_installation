#!/usr/bin/env bash
# Explicit source checkout; never reset branches or clean untracked files.
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HELPER="$SCRIPT_DIR/lib/repo_safety.py"
BACKUP_ROOT="${HOME}/.openclaw_ultimate_user_data/repo_update_backups"
[[ -f "$HELPER" && ! -L "$HELPER" ]] || {
  echo 'Sicherer Update-Helper fehlt; Abbruch.' >&2
  exit 1
}
case "${1:---dry-run}" in
  --dry-run)
    [[ $# -le 1 ]] || exit 2
    python3 -I -B "$HELPER" sync --repo "$INSTALL_DIR" --backup-root "$BACKUP_ROOT" --dry-run
    ;;
  --apply)
    [[ $# == 2 && "$2" == --confirm-discard-local ]] || {
      echo 'Explizite Freigabe --apply --confirm-discard-local erforderlich.' >&2
      exit 2
    }
    python3 -I -B "$SCRIPT_DIR/operations/installation_inventory.py" export \
      --output "$BACKUP_ROOT/installation-inventory-$(date +%Y%m%dT%H%M%S)-$$.json" --allow-workspace
    python3 -I -B "$HELPER" sync --repo "$INSTALL_DIR" --backup-root "$BACKUP_ROOT" \
      --fetch --apply --confirm-discard-local
    ;;
  *)
    echo 'Nutzung: auto_update_hard.sh [--dry-run | --apply --confirm-discard-local]' >&2
    exit 2
    ;;
esac
