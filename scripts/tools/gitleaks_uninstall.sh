#!/bin/bash
TOOL_NAME="Gitleaks"
TOOL_KEY="Gitleaks"
TOOL_SLUG="gitleaks"
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
uninstall_scaffold_tool
sudo rm -f /usr/local/bin/gitleaks
