#!/bin/bash
set -euo pipefail
TOOL_NAME="Black"
TOOL_KEY="Black"
TOOL_SLUG="black"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
