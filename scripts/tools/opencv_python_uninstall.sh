#!/bin/bash
set -euo pipefail
TOOL_NAME="OpenCV Python"
TOOL_KEY="OpenCV_Python"
TOOL_SLUG="opencv_python"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
