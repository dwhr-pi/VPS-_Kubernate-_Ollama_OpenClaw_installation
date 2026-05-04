#!/bin/bash
set -euo pipefail
TOOL_NAME="Browser Use"
TOOL_KEY="Browser_Use"
TOOL_SLUG="browser_use"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
