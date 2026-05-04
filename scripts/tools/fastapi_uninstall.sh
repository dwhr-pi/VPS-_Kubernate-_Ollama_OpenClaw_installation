#!/bin/bash
set -euo pipefail
TOOL_NAME="FastAPI"
TOOL_KEY="FastAPI"
TOOL_SLUG="fastapi"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
