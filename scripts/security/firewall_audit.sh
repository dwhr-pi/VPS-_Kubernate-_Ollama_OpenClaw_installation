#!/usr/bin/env bash
set -euo pipefail

echo "Firewall Audit"
echo "=============="

if command -v ufw >/dev/null 2>&1; then
  ufw status verbose || true
else
  echo "[WARN] UFW ist nicht installiert."
fi

echo
echo "Empfehlung:"
echo "- Standardmäßig eingehend blockieren"
echo "- Nur benötigte Ports freigeben"
