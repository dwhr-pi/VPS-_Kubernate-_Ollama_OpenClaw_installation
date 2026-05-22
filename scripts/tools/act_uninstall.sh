#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Act"

ACT_DIR="${ACT_DIR:-/opt/act}"

echo -e "${BLUE}Starte Deinstallation von Act...${NC}"
sudo rm -f /usr/local/bin/act
if [ -d "$ACT_DIR" ]; then
    sudo rm -rf "$ACT_DIR"
fi

echo -e "${GREEN}Act wurde entfernt.${NC}"
echo -e "${YELLOW}Systempakete wie git/go/build-essential bleiben erhalten, da sie auch von anderen Tools genutzt werden.${NC}"
mark_current_tool_removed
