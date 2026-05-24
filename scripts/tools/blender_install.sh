#!/usr/bin/env bash
# ==============================================================================
# BLENDER_INSTALL.SH - GitHub-Source-Installation von Blender
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
init_tool_tracking "Blender"

BLENDER_REPO_URL="${BLENDER_REPO_URL:-https://github.com/blender/blender.git}"
BLENDER_ROOT="${BLENDER_ROOT:-/opt/blender-github}"
BLENDER_SOURCE_DIR="$BLENDER_ROOT/source"
BLENDER_BUILD_DIR="$BLENDER_ROOT/build"
BLENDER_INSTALL_PREFIX="$BLENDER_ROOT/install"
BLENDER_MIN_FREE_MB="${BLENDER_MIN_FREE_MB:-51200}"
BLENDER_JOBS="${BLENDER_JOBS:-$(nproc 2>/dev/null || echo 2)}"

echo -e "${BLUE}Starte Installation von Blender aus GitHub-Quelle...${NC}"
echo -e "${YELLOW}Primaerquelle: ${BLENDER_REPO_URL}${NC}"
echo -e "${YELLOW}Achtung: Blender ist ein sehr grosser Source-Build. Plane lange Laufzeit und viel Speicher ein.${NC}"
echo -e "${YELLOW}apt wird nur fuer Compiler/Build-Abhaengigkeiten genutzt, nicht fuer die Blender-App selbst.${NC}"

if ! ensure_user_workspace || ! require_disk_mb "$BLENDER_MIN_FREE_MB" /opt; then
    echo -e "${RED}Fehler: Zu wenig freier Speicher fuer den Blender-Source-Build.${NC}"
    echo -e "${YELLOW}Empfohlen sind mindestens $((BLENDER_MIN_FREE_MB / 1024)) GB frei auf /opt.${NC}"
    exit 1
fi

ensure_base_apt_packages \
    git git-lfs subversion ca-certificates build-essential cmake ninja-build \
    python3 python3-dev python3-pip pkg-config libx11-dev libxxf86vm-dev \
    libxcursor-dev libxi-dev libxrandr-dev libxinerama-dev libegl-dev \
    libwayland-dev wayland-protocols libxkbcommon-dev libdbus-1-dev \
    libgl1-mesa-dev libglu1-mesa-dev

sudo mkdir -p "$BLENDER_ROOT"
sudo chown -R "$USER":"$USER" "$BLENDER_ROOT"

clone_or_update_github_source "$BLENDER_REPO_URL" "$BLENDER_SOURCE_DIR"

cd "$BLENDER_SOURCE_DIR"

echo -e "${BLUE}Aktualisiere Blender-Build-Abhaengigkeiten ueber Upstream-Skripte...${NC}"
echo -e "${YELLOW}Hinweis: Blender kann dabei zusaetzliche Upstream-Abhaengigkeiten nachladen. Der Quellcode selbst kommt aus GitHub.${NC}"
make update

mkdir -p "$BLENDER_BUILD_DIR" "$BLENDER_INSTALL_PREFIX"

echo -e "${BLUE}Konfiguriere Blender mit CMake/Ninja...${NC}"
cmake -S "$BLENDER_SOURCE_DIR" -B "$BLENDER_BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$BLENDER_INSTALL_PREFIX" \
    -DWITH_INSTALL_PORTABLE=OFF

echo -e "${BLUE}Baue Blender mit ${BLENDER_JOBS} Jobs...${NC}"
cmake --build "$BLENDER_BUILD_DIR" --parallel "$BLENDER_JOBS"

echo -e "${BLUE}Installiere Blender nach ${BLENDER_INSTALL_PREFIX}...${NC}"
cmake --install "$BLENDER_BUILD_DIR"

BLENDER_BIN="$(find "$BLENDER_INSTALL_PREFIX" -type f -name blender -perm -111 | head -n 1)"
if [ -z "$BLENDER_BIN" ]; then
    echo -e "${RED}Fehler: Blender wurde gebaut, aber kein ausfuehrbares blender-Binary gefunden.${NC}"
    exit 1
fi

sudo ln -sf "$BLENDER_BIN" /usr/local/bin/blender

if ! command -v blender >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Blender ist nach dem Build nicht im PATH auffindbar.${NC}"
    exit 1
fi

echo -e "${GREEN}Blender wurde erfolgreich aus GitHub-Quelle installiert.${NC}"
blender --version | head -n 2 || true
mark_current_tool_installed
