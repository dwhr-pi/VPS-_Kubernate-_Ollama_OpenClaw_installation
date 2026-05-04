#!/bin/bash
set -euo pipefail
TOOL_NAME="Ruff"
TOOL_KEY="Ruff"
TOOL_SLUG="ruff"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
