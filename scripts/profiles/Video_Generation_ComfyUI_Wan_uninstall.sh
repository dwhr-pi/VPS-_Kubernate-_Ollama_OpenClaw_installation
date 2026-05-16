#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

echo "Entferne Profilstatus: Video Generation ComfyUI Wan"
echo "Lokale ComfyUI-, Modell- und Output-Ordner bleiben zur Sicherheit erhalten."

mark_profile_removed "Video_Generation_ComfyUI_Wan"

