#!/bin/bash
# Gemeinsame Hilfsfunktionen für apt-basierte Tool-Installationen

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HELPER_DIR/../../helpers/status_tracking.sh"

install_apt_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${APT_PACKAGES:?APT_PACKAGES ist erforderlich}"

    init_tool_tracking "$TOOL_KEY"

    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Dieses Skript unterstützt aktuell nur apt-basierte Systeme.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"
    sudo apt-get update
    sudo apt-get install -y ${APT_PACKAGES}

    if [ -n "${TOOL_ENABLE_SERVICE:-}" ]; then
        sudo systemctl enable "$TOOL_ENABLE_SERVICE"
        sudo systemctl start "$TOOL_ENABLE_SERVICE"
    fi

    mark_current_tool_installed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_apt_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${APT_PACKAGES:?APT_PACKAGES ist erforderlich}"

    init_tool_tracking "$TOOL_KEY"

    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Dieses Skript unterstützt aktuell nur apt-basierte Systeme.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Starte Deinstallation von ${TOOL_NAME}...${NC}"

    if [ -n "${TOOL_ENABLE_SERVICE:-}" ]; then
        sudo systemctl stop "$TOOL_ENABLE_SERVICE" || true
        sudo systemctl disable "$TOOL_ENABLE_SERVICE" || true
    fi

    sudo apt-get remove -y ${APT_PACKAGES}
    sudo apt-get autoremove -y

    mark_current_tool_removed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich entfernt.${NC}"
}
