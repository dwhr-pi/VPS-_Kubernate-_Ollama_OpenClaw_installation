#!/usr/bin/env bash
# ==============================================================================
# BLENDER_UNINSTALL.SH - Entfernt die GitHub-Source-Installation von Blender
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Blender"

BLENDER_ROOT="${BLENDER_ROOT:-/opt/blender-github}"

echo -e "${BLUE}Starte Deinstallation der Blender-GitHub-Installation...${NC}"
sudo rm -f /usr/local/bin/blender
sudo rm -rf "$BLENDER_ROOT"

echo -e "${YELLOW}Hinweis: Build-Abhaengigkeiten aus apt werden nicht automatisch entfernt, weil sie von anderen Tools genutzt werden koennen.${NC}"
echo -e "${GREEN}Blender-GitHub-Installation wurde entfernt.${NC}"
mark_current_tool_removed
