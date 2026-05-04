#!/bin/bash
set -euo pipefail
TOOL_NAME="Tabby"
TOOL_KEY="Tabby"
TOOL_SLUG="tabby"
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
uninstall_scaffold_tool
