#!/bin/bash
TOOL_NAME="Podman"
TOOL_KEY="Podman"
APT_PACKAGES="podman"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
