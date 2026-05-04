#!/bin/bash
set -euo pipefail
TOOL_NAME="Ragas"
TOOL_KEY="Ragas"
TOOL_SLUG="ragas"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
