#!/bin/bash
set -euo pipefail
TOOL_NAME="Argilla"
TOOL_KEY="Argilla"
TOOL_SLUG="argilla"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
