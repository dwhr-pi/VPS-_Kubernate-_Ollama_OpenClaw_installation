#!/usr/bin/env bash
set -euo pipefail

GPU_SERVER_IP="${GPU_SERVER_IP:-GPU_SERVER_IP}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"
COMFYUI_PORT="${COMFYUI_PORT:-8188}"

echo "Pruefe RTX-/GPU-Server: $GPU_SERVER_IP"

if ping -c 1 -W 2 "$GPU_SERVER_IP" >/dev/null 2>&1; then
  echo "Ping: erreichbar"
else
  echo "Ping: nicht erreichbar"
  exit 1
fi

for port in "$OLLAMA_PORT" "$COMFYUI_PORT"; do
  if command -v nc >/dev/null 2>&1 && nc -z -w 2 "$GPU_SERVER_IP" "$port"; then
    echo "Port $port: offen"
  else
    echo "Port $port: nicht offen oder nc fehlt"
  fi
done
