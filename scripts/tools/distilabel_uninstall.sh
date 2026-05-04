#!/bin/bash
set -euo pipefail
TOOL_NAME="Distilabel"
TOOL_KEY="Distilabel"
TOOL_SLUG="distilabel"
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
uninstall_scaffold_tool
