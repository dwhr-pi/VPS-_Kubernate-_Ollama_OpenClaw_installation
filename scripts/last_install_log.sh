#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_LOG_DIR="${OPENCLAW_INSTALL_LOG_DIR:-$HOME/.openclaw_ultimate_user_data/install_logs}"
LOCAL_LOG_DIR="$ROOT_DIR/logs"
TAIL_LINES="${TAIL_LINES:-160}"
MODE="show"

usage() {
  cat <<'EOF'
Nutzung:
  bash scripts/last_install_log.sh
  bash scripts/last_install_log.sh --tail 240
  bash scripts/last_install_log.sh --path
  bash scripts/last_install_log.sh --email

Zeigt das neueste Installationsprotokoll aus ~/.openclaw_ultimate_user_data/install_logs
oder aus ./logs an. Mit --email wird, falls vorhanden, scripts/tool_log_diagnostics.sh genutzt.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tail)
      TAIL_LINES="${2:-160}"
      shift 2
      ;;
    --path)
      MODE="path"
      shift
      ;;
    --email|--send-email)
      MODE="email"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unbekannte Option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

latest_log="$(
  {
    find "$USER_LOG_DIR" -maxdepth 1 -type f -name '*.log' 2>/dev/null
    find "$LOCAL_LOG_DIR" -maxdepth 1 -type f -name '*.log' 2>/dev/null
  } | xargs -r ls -1t 2>/dev/null | head -n 1
)"

if [ -z "$latest_log" ]; then
  echo "Kein Installationsprotokoll gefunden." >&2
  echo "Gesucht in: $USER_LOG_DIR und $LOCAL_LOG_DIR" >&2
  exit 1
fi

case "$MODE" in
  path)
    printf '%s\n' "$latest_log"
    ;;
  email)
    if [ -f "$ROOT_DIR/scripts/tool_log_diagnostics.sh" ]; then
      bash "$ROOT_DIR/scripts/tool_log_diagnostics.sh" "$latest_log" --email-now
    else
      echo "Diagnose-Mail nicht moeglich: scripts/tool_log_diagnostics.sh fehlt." >&2
      echo "Letztes Log: $latest_log" >&2
      exit 1
    fi
    ;;
  show)
    echo "Letztes Installationsprotokoll: $latest_log"
    echo
    tail -n "$TAIL_LINES" "$latest_log"
    ;;
esac
