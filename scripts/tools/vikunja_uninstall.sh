#!/bin/bash
set -euo pipefail
TOOL_NAME="Vikunja"
TOOL_KEY="Vikunja"
TOOL_SLUG="vikunja"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
