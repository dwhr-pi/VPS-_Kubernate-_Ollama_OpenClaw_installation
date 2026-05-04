#!/bin/bash
set -euo pipefail
TOOL_NAME="Authelia"
TOOL_KEY="Authelia"
TOOL_SLUG="authelia"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
