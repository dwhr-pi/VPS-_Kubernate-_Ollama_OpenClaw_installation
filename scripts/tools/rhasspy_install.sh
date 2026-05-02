#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
confirm_heavy_install "Rhasspy" || exit 0
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_git_docker_tool "Rhasspy" "https://github.com/rhasspy/rhasspy.git" "/opt/rhasspy" $'services:\n  rhasspy:\n    image: rhasspy/rhasspy:latest\n    container_name: rhasspy\n    restart: unless-stopped\n    ports:\n      - \"12101:12101\"\n'
