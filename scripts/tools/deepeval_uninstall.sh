#!/bin/bash
set -euo pipefail
TOOL_NAME="DeepEval"
TOOL_KEY="DeepEval"
TOOL_SLUG="deepeval"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
