#!/bin/bash
set -euo pipefail
TOOL_NAME="PlatformIO"
TOOL_KEY="PlatformIO"
TOOL_SLUG="platformio"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
