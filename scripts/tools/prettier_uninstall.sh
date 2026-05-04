#!/bin/bash
set -euo pipefail
TOOL_NAME="Prettier"
TOOL_KEY="Prettier"
TOOL_SLUG="prettier"
source "$(dirname "$0")/helpers/node_tool_common.sh"
uninstall_node_tool
