#!/bin/bash
TOOL_NAME="Postgres"
TOOL_KEY="Postgres"
APT_PACKAGES="postgresql postgresql-contrib"
TOOL_ENABLE_SERVICE="postgresql"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
