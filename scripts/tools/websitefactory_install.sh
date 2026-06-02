#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="WebsiteFactory / WebBuild-Agent"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_DIR="${WEBSITEFACTORY_PROJECT_DIR:-$REPO_ROOT/tools/websitefactory}"
USER_DIR="${WEBSITEFACTORY_USER_DIR:-$HOME/.openclaw_ultimate_user_data/websitefactory}"

usage() {
  cat <<'EOF'
WebsiteFactory Setup

Usage:
  bash scripts/tools/websitefactory_install.sh [--dry-run|--status|--help]

Dieses Tool richtet nur den lokalen Workflow-Ordner ein.
Es startet bewusst keine automatischen pnpm-/Browser-Builds.
EOF
}

status() {
  echo "$TOOL_NAME Status"
  echo "Projektordner: $PROJECT_DIR"
  echo "User-Daten:    $USER_DIR"
  [[ -f "$PROJECT_DIR/package.json" ]] && echo "Tool-Projekt: vorhanden" || echo "Tool-Projekt: fehlt"
  [[ -d "$USER_DIR" ]] && echo "User-Ordner: vorhanden" || echo "User-Ordner: fehlt"
  [[ -f "$USER_DIR/.env" ]] && echo "Lokale .env: vorhanden" || echo "Lokale .env: fehlt"
}

dry_run() {
  echo "Dry-run fuer $TOOL_NAME"
  echo "Wuerde User-Ordner anlegen: $USER_DIR"
  echo "Wuerde Unterordner anlegen: $USER_DIR/output, $USER_DIR/reports"
  echo "Wuerde .env.example nach $USER_DIR/.env kopieren, falls noch keine lokale .env existiert."
  echo "Keine API-Keys, keine automatischen pnpm Builds, keine Preview-Server werden gestartet."
}

install_tool() {
  mkdir -p "$USER_DIR/output" "$USER_DIR/reports"
  if [[ -f "$PROJECT_DIR/.env.example" && ! -f "$USER_DIR/.env" ]]; then
    cp "$PROJECT_DIR/.env.example" "$USER_DIR/.env"
    chmod 600 "$USER_DIR/.env" 2>/dev/null || true
  fi
  cat > "$USER_DIR/README.local.md" <<EOF
# WebsiteFactory lokale Daten

- Tool-Projekt: $PROJECT_DIR
- Ausgaben: $USER_DIR/output
- Reports: $USER_DIR/reports
- Lokale Konfiguration: $USER_DIR/.env

Keine API-Keys ins Repository schreiben.
EOF
  echo "$TOOL_NAME wurde vorbereitet."
}

case "${1:-}" in
  --help|-h)
    usage
    ;;
  --status)
    status
    ;;
  --dry-run|--plan)
    dry_run
    ;;
  "")
    install_tool
    ;;
  *)
    echo "Unbekannte Option: $1" >&2
    usage >&2
    exit 2
    ;;
esac
