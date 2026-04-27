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

ZOTERO_DIR="/opt/zotero"

echo -e "${BLUE}Starte Deinstallation von Zotero...${NC}"

sudo rm -rf "$ZOTERO_DIR"
sudo rm -f /usr/local/bin/zotero
sudo rm -f /usr/share/applications/zotero.desktop

echo -e "${GREEN}Zotero wurde entfernt.${NC}"
