#!/bin/bash
set -euo pipefail
TOOL_NAME="Caddy"
TOOL_KEY="Caddy"
TOOL_SLUG="caddy"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
