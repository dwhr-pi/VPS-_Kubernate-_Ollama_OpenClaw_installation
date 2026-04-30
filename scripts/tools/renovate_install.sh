#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_node_tool "Renovate" "https://github.com/renovatebot/renovate.git" "/opt/renovate" "npm install && npm run build || npm install"
