#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in ffmpeg stable_diffusion_webui_forge comfyui blender; do bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" || true; done
mark_profile_removed "Game_Dev_AI"
