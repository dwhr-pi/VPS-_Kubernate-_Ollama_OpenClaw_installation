#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Appsmith" "https://github.com/appsmithorg/appsmith.git" "/opt/appsmith" $'services:\n  appsmith:\n    image: appsmith/appsmith-ce:latest\n    restart: unless-stopped\n    ports:\n      - "8090:80"'
