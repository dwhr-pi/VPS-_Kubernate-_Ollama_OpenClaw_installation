#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
TOOL_DIR="/opt/stable-diffusion-webui"
REPO_URL="${STABLE_DIFFUSION_WEBUI_REPO_URL:-https://github.com/AUTOMATIC1111/stable-diffusion-webui.git}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Stable_Diffusion_WebUI"

echo -e "${BLUE}Starte Installation von Stable Diffusion WebUI...${NC}"

sudo apt-get update
sudo apt-get install -y git python3 python3-venv python3-pip build-essential libgl1 libglib2.0-0

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
pip install --upgrade pip setuptools wheel
if [ -f requirements_versions.txt ]; then
    pip install -r requirements_versions.txt || true
elif [ -f requirements.txt ]; then
    pip install -r requirements.txt || true
fi
deactivate

mark_current_tool_installed
echo -e "${GREEN}Stable Diffusion WebUI wurde vorbereitet unter $TOOL_DIR.${NC}"
