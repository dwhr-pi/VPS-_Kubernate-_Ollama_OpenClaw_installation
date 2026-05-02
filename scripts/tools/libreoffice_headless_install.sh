#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
confirm_heavy_install "LibreOffice headless" || exit 0
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_apt_tool "LibreOffice_Headless" libreoffice
