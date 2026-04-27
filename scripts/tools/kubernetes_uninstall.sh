#!/bin/bash
TOOL_NAME="Kubernetes"
TOOL_KEY="Kubernetes"
APT_PACKAGES="apt-transport-https ca-certificates curl"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
sudo rm -f /usr/local/bin/kubectl
