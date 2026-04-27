#!/bin/bash
TOOL_NAME="Nmap"
TOOL_KEY="Nmap"
APT_PACKAGES="nmap"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
