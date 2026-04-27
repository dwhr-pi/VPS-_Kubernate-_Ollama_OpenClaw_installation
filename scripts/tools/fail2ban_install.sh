#!/bin/bash
TOOL_NAME="Fail2Ban"
TOOL_KEY="Fail2Ban"
APT_PACKAGES="fail2ban"
TOOL_ENABLE_SERVICE="fail2ban"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
install_apt_tool
