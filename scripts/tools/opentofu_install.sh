#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_node_tool "OpenTofu" "https://github.com/opentofu/opentofu.git" "/opt/opentofu" "make tools install || true"
