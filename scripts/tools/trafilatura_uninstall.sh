#!/bin/bash
set -euo pipefail
TOOL_NAME="Trafilatura"
TOOL_KEY="Trafilatura"
TOOL_SLUG="trafilatura"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
