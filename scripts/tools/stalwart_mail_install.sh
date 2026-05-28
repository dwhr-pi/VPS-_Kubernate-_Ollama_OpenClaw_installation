#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="Stalwart Mail"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MAIL_DIR="$ROOT_DIR/tools/mail"
USER_DIR="${STALWART_MAIL_USER_DIR:-$HOME/.openclaw_ultimate_user_data/mail}"
MODE="${1:---dry-run}"

usage() {
  cat <<'EOF'
Stalwart Mail Integration

Usage:
  bash scripts/tools/stalwart_mail_install.sh [--dry-run|--status|--prepare|--help]

Dieses Setup installiert keinen produktiven Mailserver automatisch.
Es bereitet lokale Konfiguration, Datenordner und Hinweise fuer Stalwart vor.
EOF
}

status() {
  echo "$TOOL_NAME Status"
  echo "Tool-Doku: $MAIL_DIR"
  echo "User-Daten: $USER_DIR"
  [[ -f "$MAIL_DIR/README.md" ]] && echo "Doku: vorhanden" || echo "Doku: fehlt"
  [[ -f "$MAIL_DIR/docker-compose.stalwart.yml" ]] && echo "Compose Vorlage: vorhanden" || echo "Compose Vorlage: fehlt"
  [[ -d "$USER_DIR" ]] && echo "User-Ordner: vorhanden" || echo "User-Ordner: fehlt"
}

dry_run() {
  echo "Dry-run fuer $TOOL_NAME"
  echo "Wuerde lokale Ordner vorbereiten:"
  echo "  $USER_DIR/config"
  echo "  $USER_DIR/data"
  echo "  $USER_DIR/backups"
  echo "  $USER_DIR/audit"
  echo "Wuerde Beispielkonfigurationen aus tools/mail/config kopieren, falls noch nicht vorhanden."
  echo "Kein offenes Relay, kein Catch-all, kein oeffentliches Admininterface und kein Auto-Send werden aktiviert."
}

prepare() {
  echo "Bereite $TOOL_NAME lokale Arbeitsdaten vor..."
  mkdir -p "$USER_DIR/config" "$USER_DIR/data" "$USER_DIR/backups" "$USER_DIR/audit"
  chmod 700 "$USER_DIR" 2>/dev/null || true

  if [[ -f "$MAIL_DIR/config/stalwart.example.toml" && ! -f "$USER_DIR/config/stalwart.toml" ]]; then
    cp "$MAIL_DIR/config/stalwart.example.toml" "$USER_DIR/config/stalwart.toml"
    chmod 600 "$USER_DIR/config/stalwart.toml" 2>/dev/null || true
    echo "Konfiguration erstellt: $USER_DIR/config/stalwart.toml"
  fi

  cat > "$USER_DIR/README.local.md" <<EOF
# Stalwart Mail lokale Daten

Dieser Ordner enthaelt lokale Mailserver-Konfiguration, Daten, Backups und Audit-Logs.

- Doku: $MAIL_DIR
- Konfiguration: $USER_DIR/config
- Daten: $USER_DIR/data
- Backups: $USER_DIR/backups
- Audit: $USER_DIR/audit

Keine DKIM Private Keys, Passwoerter oder Tokens ins Repository schreiben.
EOF

  echo "Vorbereitung abgeschlossen."
  echo "Naechster Schritt: DNS und Hardening in tools/mail/config pruefen."
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
  --prepare|--apply)
    prepare
    ;;
  *)
    echo "Unbekannte Option: $MODE" >&2
    usage >&2
    exit 2
    ;;
esac
