#!/bin/bash
# ==============================================================================
# GBOX_UNINSTALL.SH
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"

TOOL_KEY="GBOX"
GBOX_DIR="${GBOX_DIR:-/opt/gbox}"

init_tool_tracking "$TOOL_KEY"

echo -e "${BLUE}Entferne GBOX aus ${GBOX_DIR}...${NC}"
sudo rm -rf "$GBOX_DIR"
mark_current_tool_removed
echo -e "${GREEN}GBOX wurde entfernt.${NC}"
