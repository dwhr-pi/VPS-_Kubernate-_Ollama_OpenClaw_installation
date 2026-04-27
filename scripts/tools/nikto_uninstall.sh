#!/bin/bash
TOOL_NAME="Nikto"
TOOL_KEY="Nikto"
APT_PACKAGES="nikto"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
