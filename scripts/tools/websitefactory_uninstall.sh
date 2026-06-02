#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="WebsiteFactory / WebBuild-Agent"
USER_DIR="${WEBSITEFACTORY_USER_DIR:-$HOME/.openclaw_ultimate_user_data/websitefactory}"

usage() {
  cat <<'EOF'
WebsiteFactory Deinstallation

Usage:
  bash scripts/tools/websitefactory_uninstall.sh [--dry-run|--apply|--status|--help]

Der Tool-Quellcode im Repository bleibt erhalten.
EOF
}

status() {
  [[ -d "$USER_DIR" ]] && echo "User-Daten vorhanden: $USER_DIR" || echo "User-Daten fehlen: $USER_DIR"
}

dry_run() {
  echo "Dry-run fuer $TOOL_NAME"
  echo "Wuerde lokale Workflow-Daten entfernen: $USER_DIR"
}

apply_uninstall() {
  if [[ -d "$USER_DIR" ]]; then
    rm -rf "$USER_DIR"
    echo "Entfernt: $USER_DIR"
  else
    echo "Keine lokalen Daten gefunden: $USER_DIR"
  fi
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
