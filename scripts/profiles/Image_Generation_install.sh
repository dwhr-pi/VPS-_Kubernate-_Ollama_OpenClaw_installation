#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
source "$ROOT_DIR/scripts/lib/resource_check.sh"
warn_if_no_gpu
for s in comfyui stable_diffusion_webui_forge controlnet ffmpeg; do
  bash "$ROOT_DIR/scripts/tools/${s}_install.sh"
done
mark_profile_installed "Image_Generation"
