#!/bin/bash
TOOL_NAME="Uptime_Kuma"
TOOL_KEY="Uptime_Kuma"
TOOL_SLUG="uptime_kuma"
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
uninstall_github_docker_stack_tool
