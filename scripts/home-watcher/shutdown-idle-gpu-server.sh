#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
GPU_SERVER_IP="${GPU_SERVER_IP:-GPU_SERVER_IP}"
IDLE_MINUTES="${IDLE_MINUTES:-60}"
SSH_USER="${SSH_USER:-daniel}"

case "$MODE" in
  --dry-run|--apply) ;;
  --help|-h)
    echo "Usage: GPU_SERVER_IP=... bash scripts/home-watcher/shutdown-idle-gpu-server.sh [--dry-run|--apply]"
    exit 0
    ;;
  *)
    echo "Bitte --dry-run oder --apply verwenden." >&2
    exit 2
    ;;
esac

echo "Idle-Shutdown fuer GPU-Server"
echo "Server: $GPU_SERVER_IP"
echo "Idle-Minuten: $IDLE_MINUTES"

if [[ "$MODE" == "--dry-run" ]]; then
  echo "DRY-RUN: wuerde per SSH pruefen und bei Idle herunterfahren."
  exit 0
fi

ssh "${SSH_USER}@${GPU_SERVER_IP}" "echo 'TODO: lokale Idle-Pruefung einfuegen'; sudo shutdown -h +1 'GPU server idle shutdown requested'"
