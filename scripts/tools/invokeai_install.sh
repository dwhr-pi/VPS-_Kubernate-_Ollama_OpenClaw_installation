#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
confirm_heavy_install "InvokeAI" || exit 0
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_git_python_tool "InvokeAI" "https://github.com/invoke-ai/InvokeAI.git" "/opt/invokeai" ""
