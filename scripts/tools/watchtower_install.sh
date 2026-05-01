#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Watchtower" "https://github.com/containrrr/watchtower.git" "/opt/watchtower" $'services:\n  watchtower:\n    image: containrrr/watchtower:latest\n    restart: unless-stopped\n    volumes:\n      - /var/run/docker.sock:/var/run/docker.sock'
