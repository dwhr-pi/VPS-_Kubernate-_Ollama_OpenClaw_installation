#!/bin/bash
# ==============================================================================
# FFMPEG_INSTALL.SH - Installation von FFmpeg
# FFmpeg ist das zentrale CLI-Werkzeug für Audio- und Videoverarbeitung.
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Starte Installation von FFmpeg...${NC}"

if ! command -v apt-get >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Dieses Skript unterstützt aktuell nur apt-basierte Systeme.${NC}"
    exit 1
fi

sudo apt-get update
sudo apt-get install -y ffmpeg

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo -e "${RED}Fehler: FFmpeg konnte nicht installiert werden.${NC}"
    exit 1
fi

echo -e "${GREEN}FFmpeg wurde erfolgreich installiert.${NC}"
echo -e "${YELLOW}Beispiel: ffmpeg -i input.wav output.mp3${NC}"
