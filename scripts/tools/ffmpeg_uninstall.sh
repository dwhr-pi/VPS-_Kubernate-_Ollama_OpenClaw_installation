#!/usr/bin/env bash
# ==============================================================================
# FFMPEG_UNINSTALL.SH - Entfernt die GitHub-Source-Installation von FFmpeg
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
init_tool_tracking "FFmpeg"

FFMPEG_ROOT="${FFMPEG_ROOT:-/opt/ffmpeg-github}"

echo -e "${BLUE}Starte Deinstallation der FFmpeg-GitHub-Installation...${NC}"
sudo rm -f /usr/local/bin/ffmpeg /usr/local/bin/ffprobe
sudo rm -rf "$FFMPEG_ROOT"
sudo ldconfig || true

echo -e "${YELLOW}Hinweis: Build-Abhaengigkeiten aus apt werden nicht automatisch entfernt, weil sie von anderen Tools genutzt werden koennen.${NC}"
echo -e "${GREEN}FFmpeg-GitHub-Installation wurde entfernt.${NC}"
mark_current_tool_removed
