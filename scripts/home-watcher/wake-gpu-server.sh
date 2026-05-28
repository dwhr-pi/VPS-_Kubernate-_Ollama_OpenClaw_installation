#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
GPU_SERVER_MAC="${GPU_SERVER_MAC:-GPU_SERVER_MAC}"
BROADCAST_IP="${BROADCAST_IP:-255.255.255.255}"

case "$MODE" in
  --dry-run|--apply) ;;
  --help|-h)
    echo "Usage: GPU_SERVER_MAC=xx:xx:xx:xx:xx:xx bash scripts/home-watcher/wake-gpu-server.sh [--dry-run|--apply]"
    exit 0
    ;;
  *)
    echo "Bitte --dry-run oder --apply verwenden." >&2
    exit 2
    ;;
esac

echo "Wake-on-LAN fuer RTX-/GPU-Server"
echo "MAC: $GPU_SERVER_MAC"
echo "Broadcast: $BROADCAST_IP"

if [[ "$MODE" == "--dry-run" ]]; then
  echo "DRY-RUN: wuerde Magic Packet senden."
  exit 0
fi

if command -v wakeonlan >/dev/null 2>&1; then
  wakeonlan -i "$BROADCAST_IP" "$GPU_SERVER_MAC"
elif command -v etherwake >/dev/null 2>&1; then
  etherwake "$GPU_SERVER_MAC"
else
  echo "Bitte wakeonlan oder etherwake installieren." >&2
  exit 1
fi
