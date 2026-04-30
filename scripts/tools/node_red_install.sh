#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Node_RED" "https://github.com/node-red/node-red-docker.git" "/opt/node_red" $'services:\n  node-red:\n    image: nodered/node-red:latest\n    ports:\n      - "1880:1880"\n    restart: unless-stopped\n    volumes:\n      - ./data:/data'
