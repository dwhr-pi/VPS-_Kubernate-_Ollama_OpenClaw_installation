#!/bin/bash
set -euo pipefail
TOOL_NAME="SearXNG"
TOOL_KEY="SearXNG"
TOOL_SLUG="searxng"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
