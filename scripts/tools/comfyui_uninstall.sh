#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "ComfyUI"

echo -e "${BLUE}Starte Deinstallation von ComfyUI...${NC}"
sudo rm -rf /opt/comfyui
mark_current_tool_removed
echo -e "${GREEN}ComfyUI wurde entfernt.${NC}"
