#!/bin/bash
TOOL_NAME="LiteLLM"
TOOL_KEY="LiteLLM"
TOOL_SLUG="litellm"
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
uninstall_github_docker_stack_tool
