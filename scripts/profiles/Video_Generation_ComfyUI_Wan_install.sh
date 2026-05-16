#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

echo "Installiere Profil: Video Generation ComfyUI Wan"
echo "Dieses Profil nutzt denselben vorbereitenden Installer wie OpenHiggsStack."
echo "Keine grossen Wan2.x-Modelle werden automatisch heruntergeladen."

bash "$ROOT_DIR/scripts/install-openhiggsstack.sh"

mark_profile_installed "Video_Generation_ComfyUI_Wan"

