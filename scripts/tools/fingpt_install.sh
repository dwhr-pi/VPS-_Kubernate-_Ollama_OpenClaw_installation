#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

REPO_URL="$(get_custom_repo_url "FINGPT" "https://github.com/AI4Finance-Foundation/FinGPT.git")"
install_git_python_tool "FinGPT" "$REPO_URL" "/opt/fingpt" ""
