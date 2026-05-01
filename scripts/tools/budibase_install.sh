#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Budibase" "https://github.com/Budibase/budibase.git" "/opt/budibase" $'services:\n  budibase:\n    image: budibase/budibase:latest\n    restart: unless-stopped\n    ports:\n      - "10000:80"'
