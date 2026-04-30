#!/bin/bash
TOOL_NAME="GitHub_CLI"
TOOL_KEY="GitHub_CLI"
APT_PACKAGES="gh"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
