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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Zotero"

ZOTERO_DIR="/opt/zotero"
TMP_DIR="$(mktemp -d)"
ZOTERO_ARCHIVE="$TMP_DIR/zotero.tar.xz"
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
sudo apt-get install -y curl xz-utils file desktop-file-utils

echo -e "${BLUE}Lade Zotero von der offiziellen Download-Quelle herunter...${NC}"
curl -fL "$ZOTERO_DOWNLOAD_URL" -o "$ZOTERO_ARCHIVE"

archive_type="$(file -b "$ZOTERO_ARCHIVE" || true)"
echo -e "${YELLOW}Erkannter Zotero-Archivtyp:${NC} ${archive_type}"

echo -e "${BLUE}Entpacke Zotero...${NC}"
case "$archive_type" in
    *"XZ compressed data"*|*"XZ"*|*"x-xz"*)
        tar -xJf "$ZOTERO_ARCHIVE" -C "$TMP_DIR"
        ;;
    *"bzip2 compressed data"*|*"bzip2"*)
        tar -xjf "$ZOTERO_ARCHIVE" -C "$TMP_DIR"
        ;;
    *"gzip compressed data"*|*"gzip"*)
        tar -xzf "$ZOTERO_ARCHIVE" -C "$TMP_DIR"
        ;;
    *)
        echo -e "${RED}Fehler: Zotero-Download ist kein unterstuetztes tar-Archiv.${NC}"
        echo -e "${YELLOW}Quelle:${NC} $ZOTERO_DOWNLOAD_URL"
        echo -e "${YELLOW}Dateityp:${NC} $archive_type"
        echo -e "${YELLOW}Erste Bytes:${NC}"
        head -c 200 "$ZOTERO_ARCHIVE" | sed 's/[^[:print:]\t]/./g' || true
        echo
        exit 1
        ;;
esac

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
mark_current_tool_installed
