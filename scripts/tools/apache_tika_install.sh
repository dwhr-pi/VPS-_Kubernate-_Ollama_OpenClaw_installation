#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Apache_Tika" "https://github.com/apache/tika.git" "/opt/apache_tika" $'services:\n  tika:\n    image: apache/tika:latest\n    restart: unless-stopped\n    ports:\n      - "9998:9998"'
