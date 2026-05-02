#!/usr/bin/env bash
set -euo pipefail

echo "Resource Estimator"
echo "=================="

echo "Freier Speicher:"
df -h /

echo
echo "RAM:"
free -h || true

echo
echo "Docker Volumes:"
if command -v docker >/dev/null 2>&1; then
  docker system df -v || true
else
  echo "Docker nicht installiert."
fi

echo
echo "Ollama Modelle:"
if command -v ollama >/dev/null 2>&1; then
  ollama list || true
else
  echo "Ollama nicht installiert."
fi

echo
echo "GPU/VRAM:"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader || true
elif command -v rocminfo >/dev/null 2>&1; then
  rocminfo | grep -E 'Marketing Name|Compute Unit' || true
else
  echo "Keine GPU erkannt oder keine GPU-Tools installiert."
fi

echo
echo "Empfehlung:"
echo "- Bild/Video/Voice-Profile nur mit ausreichend SSD, RAM und möglichst GPU aktivieren"
echo "- Daten- und Monitoring-Stacks bei kleinem MiniPC eher auf VPS/K3s auslagern"
