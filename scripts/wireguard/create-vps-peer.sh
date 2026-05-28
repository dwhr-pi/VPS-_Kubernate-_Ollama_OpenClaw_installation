#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
WG_DIR="${WG_DIR:-$HOME/.openclaw_ultimate_user_data/wireguard}"
WG_PORT="${WG_PORT:-51820}"
VPS_PUBLIC_IP="${VPS_PUBLIC_IP:-VPS_PUBLIC_IP}"

case "$MODE" in
  --dry-run|--apply) ;;
  --help|-h)
    echo "Usage: bash scripts/wireguard/create-vps-peer.sh [--dry-run|--apply]"
    exit 0
    ;;
  *)
    echo "Bitte --dry-run oder --apply verwenden." >&2
    exit 2
    ;;
esac

echo "Erzeuge WireGuard VPS-Hub Vorlage"
echo "Zielordner: $WG_DIR"

if [[ "$MODE" == "--dry-run" ]]; then
  echo "DRY-RUN: wuerde $WG_DIR/vps-wg0.conf.example schreiben"
  exit 0
fi

mkdir -p "$WG_DIR"
chmod 700 "$WG_DIR"
cat > "$WG_DIR/vps-wg0.conf.example" <<EOF
[Interface]
Address = 10.44.0.1/24
ListenPort = ${WG_PORT}
PrivateKey = WG_PRIVATE_KEY_PLACEHOLDER

# Home watcher peer
[Peer]
PublicKey = HOME_WATCHER_PUBLIC_KEY_PLACEHOLDER
AllowedIPs = 10.44.0.2/32

# Optional GPU server peer
[Peer]
PublicKey = GPU_SERVER_PUBLIC_KEY_PLACEHOLDER
AllowedIPs = 10.44.0.3/32

# Public endpoint hint: ${VPS_PUBLIC_IP}:${WG_PORT}
EOF
chmod 600 "$WG_DIR/vps-wg0.conf.example"
echo "Geschrieben: $WG_DIR/vps-wg0.conf.example"
