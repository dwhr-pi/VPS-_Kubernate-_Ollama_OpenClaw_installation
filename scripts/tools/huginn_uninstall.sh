#!/bin/bash
# ==============================================================================
# HUGINN_UNINSTALL.SH - Deinstallation von Huginn
# ==============================================================================

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Huginn"

HUGINN_DIR="/opt/huginn"
HUGINN_SYSTEMD_WEB_SERVICE="${HUGINN_SYSTEMD_WEB_SERVICE:-huginn-web.service}"
HUGINN_SYSTEMD_WORKER_SERVICE="${HUGINN_SYSTEMD_WORKER_SERVICE:-huginn-worker.service}"

echo -e "${BLUE}Starte Deinstallation von Huginn...${NC}"

if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
    echo -e "${YELLOW}Stoppe und entferne lokale Huginn-Dienste...${NC}"
    sudo systemctl disable --now "$HUGINN_SYSTEMD_WEB_SERVICE" "$HUGINN_SYSTEMD_WORKER_SERVICE" 2>/dev/null || true
    sudo rm -f "/etc/systemd/system/${HUGINN_SYSTEMD_WEB_SERVICE}" "/etc/systemd/system/${HUGINN_SYSTEMD_WORKER_SERVICE}"
    sudo systemctl daemon-reload
fi

if [ -d "$HUGINN_DIR" ]; then
    echo -e "${YELLOW}Lösche Huginn Verzeichnis $HUGINN_DIR...${NC}"
    sudo rm -rf "$HUGINN_DIR"
    echo -e "${GREEN}Huginn erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Huginn ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

# Datenbank-Cleanup (optional und manuell)
echo -e "${YELLOW}Hinweis: Datenbank-Einträge für Huginn müssen eventuell manuell entfernt werden.${NC}"

echo -e "${GREEN}Huginn Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed
