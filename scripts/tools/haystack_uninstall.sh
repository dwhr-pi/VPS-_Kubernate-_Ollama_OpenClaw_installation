#!/bin/bash
set -euo pipefail
TOOL_NAME="Haystack"
TOOL_KEY="Haystack"
TOOL_SLUG="haystack"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
