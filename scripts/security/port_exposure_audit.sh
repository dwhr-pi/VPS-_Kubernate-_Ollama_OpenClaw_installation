#!/usr/bin/env bash
set -euo pipefail

echo "Port Exposure Audit"
echo "==================="

if ! command -v ss >/dev/null 2>&1; then
  echo "[WARN] 'ss' nicht verfügbar."
  exit 0
fi

ss -ltnp | awk 'NR==1 || /0\\.0\\.0\\.0:|\\[::\\]:/'
echo
echo "Hinweis:"
echo "- Prüfe besonders Bindings an 0.0.0.0 oder [::]"
echo "- Öffentliche Ports nur mit Auth, Firewall und HTTPS freigeben"
