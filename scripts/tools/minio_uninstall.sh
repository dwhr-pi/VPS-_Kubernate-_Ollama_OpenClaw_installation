#!/bin/bash
TOOL_NAME="MinIO"
TOOL_KEY="MinIO"
TOOL_SLUG="minio"
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
uninstall_github_docker_stack_tool
