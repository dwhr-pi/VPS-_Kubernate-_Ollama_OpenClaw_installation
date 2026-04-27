#!/bin/bash
TOOL_NAME="Prometheus"
TOOL_KEY="Prometheus"
TOOL_SLUG="prometheus"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
