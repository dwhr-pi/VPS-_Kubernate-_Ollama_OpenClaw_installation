#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$SCRIPT_DIR/tools/electronics_dev_install.sh"

echo "Profil Elektronik_Entwickler vorbereitet."
echo "Optionale Erweiterungen:"
echo "  ELECTRONICS_INSTALL_NODE_TOOLS=1 bash scripts/tools/electronics_dev_install.sh"
echo "  ELECTRONICS_INSTALL_MCP_TOOLS=1 bash scripts/tools/electronics_dev_install.sh"
echo "  ELECTRONICS_INSTALL_HEAVY_EDA=1 bash scripts/tools/electronics_dev_install.sh"

