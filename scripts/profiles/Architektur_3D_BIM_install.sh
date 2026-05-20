#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$SCRIPT_DIR/tools/architecture_bim_install.sh"

echo "Profil Architektur_3D_BIM vorbereitet."
echo "Optionale Erweiterung:"
echo "  ARCHITECTURE_INSTALL_HEAVY_TOOLS=1 bash scripts/tools/architecture_bim_install.sh"

