#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Airbyte" "https://github.com/airbytehq/airbyte.git" "/opt/airbyte" $'services:\n  airbyte-webapp:\n    image: airbyte/webapp:latest\n    ports:\n      - "8003:80"\n    restart: unless-stopped'
