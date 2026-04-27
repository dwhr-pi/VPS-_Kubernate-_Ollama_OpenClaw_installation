#!/bin/bash
# ==============================================================================
# ZOTERO_INSTALL.SH - Installation von Zotero
# Installiert die offizielle Linux-Version von Zotero unter /opt/zotero.
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ZOTERO_DIR="/opt/zotero"
TMP_DIR="$(mktemp -d)"
ZOTERO_ARCHIVE="$TMP_DIR/zotero.tar.bz2"
ZOTERO_DOWNLOAD_URL="https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo -e "${BLUE}Starte Installation von Zotero...${NC}"

if ! command -v apt-get >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Dieses Skript unterstützt aktuell nur apt-basierte Systeme.${NC}"
    exit 1
fi

sudo apt-get update
sudo apt-get install -y curl bzip2 desktop-file-utils

echo -e "${BLUE}Lade Zotero von der offiziellen Download-Quelle herunter...${NC}"
curl -L "$ZOTERO_DOWNLOAD_URL" -o "$ZOTERO_ARCHIVE"

echo -e "${BLUE}Entpacke Zotero...${NC}"
tar -xjf "$ZOTERO_ARCHIVE" -C "$TMP_DIR"

EXTRACTED_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name 'Zotero*' | head -n 1)"
if [ -z "$EXTRACTED_DIR" ] || [ ! -f "$EXTRACTED_DIR/zotero" ]; then
    echo -e "${RED}Fehler: Die Zotero-Installation konnte nicht aus dem Archiv erkannt werden.${NC}"
    exit 1
fi

sudo rm -rf "$ZOTERO_DIR"
sudo mv "$EXTRACTED_DIR" "$ZOTERO_DIR"
sudo ln -sf "$ZOTERO_DIR/zotero" /usr/local/bin/zotero

if [ -f "$ZOTERO_DIR/zotero.desktop" ]; then
    sudo cp "$ZOTERO_DIR/zotero.desktop" /usr/share/applications/zotero.desktop
fi

echo -e "${GREEN}Zotero wurde unter ${ZOTERO_DIR} installiert.${NC}"
echo -e "${YELLOW}CLI-Start: zotero${NC}"
