#!/bin/bash
set -euo pipefail
TOOL_NAME="pytest"
TOOL_KEY="Pytest"
TOOL_SLUG="pytest"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
