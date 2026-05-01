#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in comfyui animatediff svd ffmpeg realesrgan; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Video_Generation_Studio"
