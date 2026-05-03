#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

REPO_URL="$(get_custom_repo_url "FINROBOT" "https://github.com/AI4Finance-Foundation/FinRobot.git")"
install_git_python_tool "FinRobot" "$REPO_URL" "/opt/finrobot" ""
