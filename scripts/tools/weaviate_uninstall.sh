#!/bin/bash
TOOL_NAME="Weaviate"
TOOL_KEY="Weaviate"
TOOL_SLUG="weaviate"
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
uninstall_docker_compose_tool
