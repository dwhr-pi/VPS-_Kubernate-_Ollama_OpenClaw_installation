#!/bin/bash
set -euo pipefail
TOOL_NAME="changedetection.io"
TOOL_KEY="Changedetection_IO"
TOOL_SLUG="changedetection_io"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
