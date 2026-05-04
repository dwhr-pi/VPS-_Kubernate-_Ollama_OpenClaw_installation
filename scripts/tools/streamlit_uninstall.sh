#!/bin/bash
set -euo pipefail
TOOL_NAME="Streamlit"
TOOL_KEY="Streamlit"
TOOL_SLUG="streamlit"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
