#!/usr/bin/env bash
# ==============================================================================
# FFMPEG_INSTALL.SH - GitHub-Source-Installation von FFmpeg
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
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/tools/helpers/simple_tool_common.sh"
init_tool_tracking "FFmpeg"

FFMPEG_REPO_URL="${FFMPEG_REPO_URL:-https://github.com/FFmpeg/FFmpeg.git}"
FFMPEG_ROOT="${FFMPEG_ROOT:-/opt/ffmpeg-github}"
FFMPEG_SOURCE_DIR="$FFMPEG_ROOT/source"
FFMPEG_PREFIX="$FFMPEG_ROOT/build"
FFMPEG_MIN_FREE_MB="${FFMPEG_MIN_FREE_MB:-4096}"
FFMPEG_JOBS="${FFMPEG_JOBS:-$(nproc 2>/dev/null || echo 2)}"

echo -e "${BLUE}Starte Installation von FFmpeg aus GitHub-Quelle...${NC}"
echo -e "${YELLOW}Primaerquelle: ${FFMPEG_REPO_URL}${NC}"
echo -e "${YELLOW}Hinweis: apt wird nur fuer Compiler/Build-Abhaengigkeiten genutzt, nicht fuer die FFmpeg-App selbst.${NC}"

if ! ensure_user_workspace || ! require_disk_mb "$FFMPEG_MIN_FREE_MB" /opt; then
    echo -e "${RED}Fehler: Zu wenig freier Speicher fuer den FFmpeg-Source-Build.${NC}"
    exit 1
fi

ensure_base_apt_packages git ca-certificates build-essential pkg-config yasm nasm cmake autoconf automake libtool

sudo mkdir -p "$FFMPEG_ROOT"
sudo chown -R "$USER":"$USER" "$FFMPEG_ROOT"

clone_or_update_github_source "$FFMPEG_REPO_URL" "$FFMPEG_SOURCE_DIR"

cd "$FFMPEG_SOURCE_DIR"

echo -e "${BLUE}Konfiguriere FFmpeg Source-Build...${NC}"
./configure \
    --prefix="$FFMPEG_PREFIX" \
    --disable-debug \
    --disable-doc \
    --disable-static \
    --enable-shared

echo -e "${BLUE}Baue FFmpeg mit ${FFMPEG_JOBS} Jobs...${NC}"
make -j "$FFMPEG_JOBS"

echo -e "${BLUE}Installiere FFmpeg nach ${FFMPEG_PREFIX}...${NC}"
make install

sudo ln -sf "$FFMPEG_PREFIX/bin/ffmpeg" /usr/local/bin/ffmpeg
sudo ln -sf "$FFMPEG_PREFIX/bin/ffprobe" /usr/local/bin/ffprobe
sudo ldconfig

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo -e "${RED}Fehler: FFmpeg wurde gebaut, ist aber nicht im PATH auffindbar.${NC}"
    exit 1
fi

echo -e "${GREEN}FFmpeg wurde erfolgreich aus GitHub-Quelle installiert.${NC}"
ffmpeg -version | head -n 1 || true
mark_current_tool_installed
