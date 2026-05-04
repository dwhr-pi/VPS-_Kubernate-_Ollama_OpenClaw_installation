#!/bin/bash
set -euo pipefail
TOOL_NAME="Dev Container CLI"
TOOL_KEY="Devcontainer_CLI"
TOOL_SLUG="devcontainer_cli"
source "$(dirname "$0")/helpers/node_tool_common.sh"
uninstall_node_tool
