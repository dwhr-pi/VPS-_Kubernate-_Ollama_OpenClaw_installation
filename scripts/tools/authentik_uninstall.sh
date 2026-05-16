#!/bin/bash
# ==============================================================================
# AUTHENTIK_UNINSTALL.SH - Entfernt Authentik aus dem Setup-Status
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Authentik"

echo -e "${YELLOW}Authentik-Vorlagen im User-Workspace bleiben erhalten, damit keine lokale Konfiguration verloren geht.${NC}"
mark_current_tool_removed
echo -e "${GREEN}Authentik wurde aus dem Setup-Status entfernt.${NC}"
