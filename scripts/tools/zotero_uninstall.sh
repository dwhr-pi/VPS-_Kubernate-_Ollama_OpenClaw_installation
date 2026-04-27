#!/bin/bash
# ==============================================================================
# ZOTERO_UNINSTALL.SH - Deinstallation von Zotero
# ==============================================================================

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
init_tool_tracking "Zotero"

ZOTERO_DIR="/opt/zotero"

echo -e "${BLUE}Starte Deinstallation von Zotero...${NC}"

sudo rm -rf "$ZOTERO_DIR"
sudo rm -f /usr/local/bin/zotero
sudo rm -f /usr/share/applications/zotero.desktop

echo -e "${GREEN}Zotero wurde entfernt.${NC}"
mark_current_tool_removed

