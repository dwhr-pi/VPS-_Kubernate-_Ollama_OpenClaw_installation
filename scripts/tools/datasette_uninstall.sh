#!/bin/bash
set -euo pipefail
TOOL_NAME="Datasette"
TOOL_KEY="Datasette"
TOOL_SLUG="datasette"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
