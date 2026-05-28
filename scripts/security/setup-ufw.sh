#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
SSH_PORT="${SSH_PORT:-22}"
WG_PORT="${WG_PORT:-51820}"

run() {
  if [[ "$MODE" == "--apply" ]]; then
    "$@"
  else
    printf 'DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
  fi
}

case "$MODE" in
  --dry-run|--apply) ;;
  --help|-h)
    echo "Usage: sudo bash scripts/security/setup-ufw.sh [--dry-run|--apply]"
    exit 0
    ;;
  *)
    echo "Bitte --dry-run oder --apply verwenden." >&2
    exit 2
    ;;
esac

echo "UFW Hardening fuer Oracle VPS"
echo "Erlaubt: 80/tcp, 443/tcp, ${WG_PORT}/udp, SSH ${SSH_PORT}/tcp limitiert"
echo "Nicht oeffnen: Ollama, OpenClaw, Kubernetes API, Home Assistant, ComfyUI, Datenbanken"

run ufw default deny incoming
run ufw default allow outgoing
run ufw allow 80/tcp
run ufw allow 443/tcp
run ufw allow "${WG_PORT}/udp"
run ufw limit "${SSH_PORT}/tcp"
run ufw status verbose

if [[ "$MODE" == "--apply" ]]; then
  echo "Aktiviere UFW nur, wenn du SSH/WireGuard-Zugriff geprueft hast."
  ufw --force enable
fi
