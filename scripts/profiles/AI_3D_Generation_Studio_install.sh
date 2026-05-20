#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$SCRIPT_DIR/tools/ai_3d_studio_install.sh"

echo "AI_3D_Generation_Studio Profil vorbereitet."
echo "Naechste optionale Schritte:"
echo "  bash scripts/tools/hunyuan3d_install.sh"
echo "  bash scripts/tools/triposr_install.sh"
echo "  AI3D_INSTALL_COMFY_NODES=1 bash scripts/tools/ai_3d_studio_install.sh"

