#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
TOOL_DIR="/opt/comfyui"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/lib/common.sh"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/lib/resource_check.sh"
REPO_URL="${COMFYUI_REPO_URL:-$(get_custom_repo_url "COMFYUI" "https://github.com/comfyanonymous/ComfyUI.git")}"
init_tool_tracking "ComfyUI"

echo -e "${BLUE}Starte Installation von ComfyUI...${NC}"
echo -e "${YELLOW}ComfyUI installiert PyTorch/CUDA-nahe Pakete und kann ohne Modelle bereits viele GB belegen.${NC}"
echo -e "${YELLOW}Mindestprüfung: 40 GB freier Linux-/WSL-Speicher, unter WSL zusätzlich 30 GB Windows-Host-Speicher auf C:.${NC}"
REQUIRE_WINDOWS_HOST_FREE_MB="${COMFYUI_MIN_WINDOWS_HOST_FREE_MB:-30720}"
require_disk_mb "${COMFYUI_MIN_FREE_MB:-40960}" "/"

sudo apt-get update
sudo apt-get install -y git python3 python3-venv python3-pip build-essential

if [ -d "$TOOL_DIR/.git" ]; then
    git -C "$TOOL_DIR" pull --ff-only
else
    sudo mkdir -p "$TOOL_DIR"
    sudo chown -R "$USER:$USER" "$TOOL_DIR"
    git clone "$REPO_URL" "$TOOL_DIR"
fi

cd "$TOOL_DIR"
if [ ! -d venv ]; then
    python3 -m venv venv
fi
# shellcheck disable=SC1091
source venv/bin/activate
export PIP_NO_CACHE_DIR=1
pip install --no-cache-dir --upgrade pip setuptools wheel
if [ -f requirements.txt ]; then
    if ! pip install --no-cache-dir -r requirements.txt; then
        echo -e "${RED}Fehler: pip install fuer ComfyUI ist fehlgeschlagen.${NC}"
        echo -e "${YELLOW}Typische Ursache bei WSL: zu wenig freier Linux-/Windows-Host-Speicher waehrend PyTorch/CUDA-Pakete entpackt werden.${NC}"
        echo -e "${YELLOW}Aufraeumen: bash scripts/cleanup_installation_residues.sh --apply --all und ggf. sudo rm -rf /opt/comfyui/venv${NC}"
        deactivate || true
        exit 1
    fi
fi
deactivate

mark_current_tool_installed
echo -e "${GREEN}ComfyUI wurde vorbereitet unter $TOOL_DIR.${NC}"
