#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -x "$ROOT_DIR/scripts/security/check_supply_chain.sh" ]]; then
  exec "$ROOT_DIR/scripts/security/check_supply_chain.sh"
fi

echo "Supply-Chain-Scan: Basismodus"
echo "- Pruefe auf curl|bash Hinweise."
echo "- Pruefe auf fehlende Quellen in config/tools.yml ueber scripts/check_tools.sh."

if command -v rg >/dev/null 2>&1; then
  rg -n --hidden --glob '!.git/**' 'curl .*[|] *bash|wget .*[|] *sh' "$ROOT_DIR/scripts" "$ROOT_DIR/docs" || true
else
  echo "INFO: rg nicht gefunden; Musterpruefung uebersprungen."
fi

bash "$ROOT_DIR/scripts/check_tools.sh" || true

