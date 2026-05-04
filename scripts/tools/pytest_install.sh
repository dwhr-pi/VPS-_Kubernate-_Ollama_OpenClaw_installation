#!/bin/bash
set -euo pipefail
TOOL_NAME="pytest"
TOOL_KEY="Pytest"
TOOL_SLUG="pytest"
TOOL_PACKAGES="pytest"
TOOL_DESCRIPTION="Python-Testframework für Repository-Checks, Agenten-Patches und Eval-Regressionsläufe."
TOOL_OPENCLAW_NOTE="Wichtig für lokale Coding-Agenten und produktionsnähere Python-Workflows."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
