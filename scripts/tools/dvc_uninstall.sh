#!/bin/bash
set -euo pipefail
TOOL_NAME="DVC"
TOOL_KEY="DVC"
TOOL_SLUG="dvc"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
