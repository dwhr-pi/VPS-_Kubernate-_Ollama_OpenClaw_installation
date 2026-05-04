#!/bin/bash
set -euo pipefail
TOOL_NAME="Label Studio"
TOOL_KEY="Label_Studio"
TOOL_SLUG="label_studio"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
