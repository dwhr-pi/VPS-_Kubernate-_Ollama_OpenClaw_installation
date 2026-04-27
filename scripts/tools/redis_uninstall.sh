#!/bin/bash
TOOL_NAME="Redis"
TOOL_KEY="Redis"
APT_PACKAGES="redis-server"
TOOL_ENABLE_SERVICE="redis-server"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
