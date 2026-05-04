#!/bin/bash
set -euo pipefail
TOOL_NAME="TruLens"
TOOL_KEY="TruLens"
TOOL_SLUG="trulens"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
