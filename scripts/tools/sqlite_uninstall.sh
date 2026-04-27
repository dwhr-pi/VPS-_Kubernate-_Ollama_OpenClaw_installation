#!/bin/bash
TOOL_NAME="SQLite"
TOOL_KEY="SQLite"
APT_PACKAGES="sqlite3"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
