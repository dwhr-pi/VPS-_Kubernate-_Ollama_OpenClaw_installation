#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_git_python_tool "SQLite_Vec" "https://github.com/asg017/sqlite-vec.git" "/opt/sqlite-vec" ""
