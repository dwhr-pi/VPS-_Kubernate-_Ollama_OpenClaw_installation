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

if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}Fehler: curl wird für die Tailscale-Installation benötigt.${NC}"
    exit 1
fi

echo -e "${BLUE}Starte Installation von Tailscale...${NC}"
echo -e "${YELLOW}Es wird der offizielle Linux-Installer von tailscale.com verwendet.${NC}"

curl -fsSL https://tailscale.com/install.sh | sh

if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable tailscaled >/dev/null 2>&1 || true
    sudo systemctl start tailscaled >/dev/null 2>&1 || true
fi

echo -e "${GREEN}Tailscale wurde installiert.${NC}"
echo -e "${YELLOW}Nächster manueller Schritt: sudo tailscale up${NC}"
echo -e "${YELLOW}Empfehlung: Für private Admin-Zugriffe Tailscale statt offener Panel-Ports nutzen.${NC}"
mark_current_tool_installed
