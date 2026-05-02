#!/usr/bin/env bash
set -euo pipefail

echo "Docker Socket Audit"
echo "==================="

if [ -S /var/run/docker.sock ]; then
  ls -l /var/run/docker.sock
  echo "[WARN] Docker-Socket vorhanden. Root-äquivalentes Risiko für lokale Agenten beachten."
else
  echo "[OK] Kein Docker-Socket unter /var/run/docker.sock gefunden."
fi
