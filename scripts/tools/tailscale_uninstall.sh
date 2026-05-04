#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"

init_tool_tracking "Tailscale"

echo -e "${BLUE}Starte Deinstallation von Tailscale...${NC}"

if command -v tailscale >/dev/null 2>&1; then
    sudo tailscale down >/dev/null 2>&1 || true
fi

if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl stop tailscaled >/dev/null 2>&1 || true
    sudo systemctl disable tailscaled >/dev/null 2>&1 || true
fi

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get remove -y tailscale || true
    sudo rm -f /etc/apt/sources.list.d/tailscale.list
    sudo rm -f /usr/share/keyrings/tailscale-archive-keyring.gpg
    sudo apt-get update || true
    sudo apt-get autoremove -y || true
else
    echo -e "${YELLOW}Hinweis: apt-get wurde nicht gefunden. Bitte Tailscale auf diesem System manuell entfernen.${NC}"
fi

echo -e "${GREEN}Tailscale wurde entfernt.${NC}"
mark_current_tool_removed
