#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
WG_DIR="${WG_DIR:-$HOME/.openclaw_ultimate_user_data/wireguard}"
VPS_PUBLIC_IP="${VPS_PUBLIC_IP:-VPS_PUBLIC_IP}"
WG_PORT="${WG_PORT:-51820}"

case "$MODE" in
  --dry-run|--apply) ;;
  --help|-h)
    echo "Usage: bash scripts/wireguard/create-home-peer.sh [--dry-run|--apply]"
    exit 0
    ;;
  *)
    echo "Bitte --dry-run oder --apply verwenden." >&2
    exit 2
    ;;
esac

echo "Erzeuge WireGuard Home-Waechter Vorlage"
echo "Zielordner: $WG_DIR"

if [[ "$MODE" == "--dry-run" ]]; then
  echo "DRY-RUN: wuerde $WG_DIR/home-watcher.conf.example schreiben"
  exit 0
fi

mkdir -p "$WG_DIR"
chmod 700 "$WG_DIR"
cat > "$WG_DIR/home-watcher.conf.example" <<EOF
[Interface]
Address = 10.44.0.2/24
PrivateKey = WG_PRIVATE_KEY_PLACEHOLDER

[Peer]
PublicKey = VPS_PUBLIC_KEY_PLACEHOLDER
Endpoint = ${VPS_PUBLIC_IP}:${WG_PORT}
AllowedIPs = 10.44.0.0/24
PersistentKeepalive = 25
EOF
chmod 600 "$WG_DIR/home-watcher.conf.example"
echo "Geschrieben: $WG_DIR/home-watcher.conf.example"
