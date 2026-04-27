#!/bin/bash
# ==============================================================================
# FFMPEG_UNINSTALL.SH - Deinstallation von FFmpeg
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Starte Deinstallation von FFmpeg...${NC}"

if ! command -v apt-get >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Dieses Skript unterstützt aktuell nur apt-basierte Systeme.${NC}"
    exit 1
fi

sudo apt-get remove -y ffmpeg
sudo apt-get autoremove -y

echo -e "${GREEN}FFmpeg wurde deinstalliert.${NC}"
