#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_python_tool "Pre_Commit_Hooks" "https://github.com/pre-commit/pre-commit.git" "/opt/pre_commit"
