#!/bin/bash
set -euo pipefail
TOOL_NAME="Gradio"
TOOL_KEY="Gradio"
TOOL_SLUG="gradio"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
