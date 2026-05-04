#!/bin/bash
set -euo pipefail
TOOL_NAME="ESLint"
TOOL_KEY="ESLint"
TOOL_SLUG="eslint"
source "$(dirname "$0")/helpers/node_tool_common.sh"
uninstall_node_tool
