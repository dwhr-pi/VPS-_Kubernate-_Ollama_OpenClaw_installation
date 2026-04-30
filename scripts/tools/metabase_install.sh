#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Metabase" "https://github.com/metabase/metabase.git" "/opt/metabase" $'services:\n  metabase:\n    image: metabase/metabase:latest\n    ports:\n      - "3006:3000"\n    restart: unless-stopped'
