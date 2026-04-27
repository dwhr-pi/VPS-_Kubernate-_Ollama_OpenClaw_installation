#!/bin/bash
# ==============================================================================
# PIPEDREAM_UNINSTALL.SH - Deinstallation von Pipedream (Self-Hosted)
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Pipedream"

PIPEDREAM_DIR="/opt/pipedream"

echo -e "${BLUE}Starte Deinstallation von Pipedream (Self-Hosted)...${NC}"

if [ -d "$PIPEDREAM_DIR" ]; then
    echo -e "${YELLOW}Lösche Pipedream Verzeichnis $PIPEDREAM_DIR...${NC}"
    sudo rm -rf "$PIPEDREAM_DIR"
    echo -e "${GREEN}Pipedream erfolgreich deinstalliert (falls lokal geklont).${NC}"
else
    echo -e "${YELLOW}Pipedream ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${YELLOW}Hinweis: Wenn Pipedream über Docker/Kubernetes installiert wurde, müssen Sie die entsprechenden Container/Pods/Deployments manuell entfernen.${NC}"

echo -e "${GREEN}Pipedream Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed

