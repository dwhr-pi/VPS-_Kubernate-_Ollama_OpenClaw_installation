#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "Keine NVIDIA-GPU erkannt. Profil wird nur vorbereitet; GPU-Tools werden nicht blind installiert."
    mkdir -p "$HOME/.openclaw_ultimate_user_data/profiles/render-farm-gpu-workstation"
else
    for s in comfyui stable_diffusion_webui_forge blender realesrgan; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
fi
mark_profile_installed "Render_Farm_GPU_Workstation"
