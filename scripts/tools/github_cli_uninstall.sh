#!/bin/bash
TOOL_NAME="GitHub_CLI"
TOOL_KEY="GitHub_CLI"
TOOL_SLUG="github_cli"
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
uninstall_scaffold_tool
sudo rm -f /usr/local/bin/gh
