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

init_tool_tracking "Cloudflared"

if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}Fehler: curl wird für die Cloudflared-Installation benötigt.${NC}"
    exit 1
fi

if ! command -v dpkg >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Dieses Skript ist aktuell für Debian/Ubuntu-Systeme gedacht.${NC}"
    exit 1
fi

ARCH="$(dpkg --print-architecture)"
TMP_DEB="/tmp/cloudflared-linux-${ARCH}.deb"

echo -e "${BLUE}Starte Installation von cloudflared...${NC}"
echo -e "${YELLOW}Es wird das aktuelle Linux-.deb nach offizieller Cloudflare-Empfehlung geladen.${NC}"

curl -fsSL --output "$TMP_DEB" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}.deb"
sudo dpkg -i "$TMP_DEB" || sudo apt-get install -f -y
rm -f "$TMP_DEB"

echo -e "${GREEN}cloudflared wurde installiert.${NC}"
echo -e "${YELLOW}Für produktive Tunnel folgt der nächste Schritt manuell, z. B.: sudo cloudflared service install <TUNNEL_TOKEN>${NC}"
mark_current_tool_installed
