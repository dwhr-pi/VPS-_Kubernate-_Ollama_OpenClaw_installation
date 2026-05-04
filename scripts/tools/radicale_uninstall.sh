#!/bin/bash
set -euo pipefail
TOOL_NAME="Radicale"
TOOL_KEY="Radicale"
TOOL_SLUG="radicale"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
