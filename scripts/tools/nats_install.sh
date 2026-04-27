#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
TOOL_DIR="/opt/nats"
VERSION="${NATS_VERSION:-v2.10.24}"
ARCHIVE="nats-server-${VERSION}-linux-amd64.tar.gz"
URL="https://github.com/nats-io/nats-server/releases/download/${VERSION}/${ARCHIVE}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "NATS"

echo -e "${BLUE}Starte Installation von NATS...${NC}"
sudo apt-get update
sudo apt-get install -y curl tar
sudo mkdir -p "$TOOL_DIR"
sudo chown -R "$USER:$USER" "$TOOL_DIR"
cd "$TOOL_DIR"
curl -fsSLO "$URL"
tar -xzf "$ARCHIVE" --strip-components=1
sudo ln -sf "$TOOL_DIR/nats-server" /usr/local/bin/nats-server
mark_current_tool_installed
echo -e "${GREEN}NATS wurde erfolgreich installiert.${NC}"
