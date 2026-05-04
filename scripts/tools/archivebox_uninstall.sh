#!/bin/bash
set -euo pipefail
TOOL_NAME="ArchiveBox"
TOOL_KEY="ArchiveBox"
TOOL_SLUG="archivebox"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
