#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
echo "GPU-Modelle und Renderdaten werden nicht automatisch geloescht."
mark_profile_removed "Render_Farm_GPU_Workstation"
