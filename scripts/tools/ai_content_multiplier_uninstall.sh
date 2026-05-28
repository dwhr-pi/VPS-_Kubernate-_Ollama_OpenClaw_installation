#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="AI-ContentMultiplier"
PROJECT_DIR="${AI_CONTENT_MULTIPLIER_PROJECT_DIR:-/mnt/c/Users/danie/Documents/GitHub/content-multiplier}"
USER_DIR="${AI_CONTENT_MULTIPLIER_USER_DIR:-$HOME/.openclaw_ultimate_user_data/content-multiplier}"

if [[ "$PROJECT_DIR" == /mnt/c/* && ! -e "$PROJECT_DIR" && -e "/c/${PROJECT_DIR#/mnt/c/}" ]]; then
  PROJECT_DIR="/c/${PROJECT_DIR#/mnt/c/}"
fi

usage() {
  cat <<'EOF'
AI-ContentMultiplier Workflow-Deinstallation

Usage:
  bash scripts/tools/ai_content_multiplier_uninstall.sh [--dry-run|--apply|--status|--help]

Standard ist sicher: ohne --apply wird nichts geloescht.
Der Projektordner wird nicht automatisch entfernt.
EOF
}

status() {
  echo "$TOOL_NAME Status"
  [[ -d "$PROJECT_DIR" ]] && echo "Projektordner vorhanden: $PROJECT_DIR" || echo "Projektordner fehlt: $PROJECT_DIR"
  [[ -d "$USER_DIR" ]] && echo "User-Daten vorhanden: $USER_DIR" || echo "User-Daten fehlen: $USER_DIR"
}

dry_run() {
  echo "Dry-run fuer $TOOL_NAME Deinstallation"
  echo "Wuerde lokale Workflow-Daten entfernen: $USER_DIR"
  echo "Projektordner bleibt erhalten: $PROJECT_DIR"
}

apply_uninstall() {
  echo "Entferne lokale Workflow-Daten fuer $TOOL_NAME..."
  if [[ -d "$USER_DIR" ]]; then
    rm -rf "$USER_DIR"
    echo "Entfernt: $USER_DIR"
  else
    echo "Keine lokalen Workflow-Daten gefunden: $USER_DIR"
  fi
  echo "Projektordner wurde nicht geloescht: $PROJECT_DIR"
}

case "${1:---dry-run}" in
  --help|-h)
    usage
    ;;
  --status)
    status
    ;;
  --dry-run|--plan|"")
    dry_run
    ;;
  --apply)
    apply_uninstall
    ;;
  *)
    echo "Unbekannte Option: $1" >&2
    usage >&2
    exit 2
    ;;
esac
