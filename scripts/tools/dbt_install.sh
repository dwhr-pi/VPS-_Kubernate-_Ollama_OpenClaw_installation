#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_python_tool "dbt" "https://github.com/dbt-labs/dbt-core.git" "/opt/dbt_core"
