#!/bin/bash
set -euo pipefail
TOOL_NAME="Microsoft Presidio"
TOOL_KEY="Presidio"
TOOL_SLUG="presidio"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
