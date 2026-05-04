#!/bin/bash
set -euo pipefail
TOOL_NAME="LM Evaluation Harness"
TOOL_KEY="LM_Evaluation_Harness"
TOOL_SLUG="lm_evaluation_harness"
source "$(dirname "$0")/helpers/python_tool_common.sh"
uninstall_python_tool
