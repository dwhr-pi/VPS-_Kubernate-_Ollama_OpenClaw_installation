#!/bin/bash
TOOL_NAME="Grafana"
TOOL_KEY="Grafana"
TOOL_SLUG="grafana"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
