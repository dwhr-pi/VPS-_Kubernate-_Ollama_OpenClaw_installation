#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "NocoDB" "https://github.com/nocodb/nocodb.git" "/opt/nocodb" $'services:\n  nocodb:\n    image: nocodb/nocodb:latest\n    restart: unless-stopped\n    ports:\n      - "8083:8080"'
