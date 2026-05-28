#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="Stalwart Mail"
USER_DIR="${STALWART_MAIL_USER_DIR:-$HOME/.openclaw_ultimate_user_data/mail}"
MODE="${1:---dry-run}"

usage() {
  cat <<'EOF'
Stalwart Mail Deinstallation

Usage:
  bash scripts/tools/stalwart_mail_uninstall.sh [--dry-run|--apply|--status|--help]

Standard ist sicher: ohne --apply wird nichts geloescht.
EOF
}

status() {
  [[ -d "$USER_DIR" ]] && echo "$TOOL_NAME User-Daten vorhanden: $USER_DIR" || echo "$TOOL_NAME User-Daten fehlen: $USER_DIR"
}

dry_run() {
  echo "Dry-run fuer $TOOL_NAME"
  echo "Wuerde lokale Stalwart-Mail-Arbeitsdaten entfernen: $USER_DIR"
  echo "Produktive Maildaten nur loeschen, wenn Backups/Restore geprueft wurden."
}

apply_uninstall() {
  echo "Entferne lokale Stalwart-Mail-Arbeitsdaten..."
  if [[ -d "$USER_DIR" ]]; then
    rm -rf "$USER_DIR"
    echo "Entfernt: $USER_DIR"
  else
    echo "Nichts zu entfernen: $USER_DIR"
  fi
}

case "$MODE" in
  --help|-h)
    usage
    ;;
  --status)
    status
    ;;
  --dry-run|--plan)
    dry_run
    ;;
  --apply)
    apply_uninstall
    ;;
  *)
    echo "Unbekannte Option: $MODE" >&2
    usage >&2
    exit 2
    ;;
esac
