#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Forgejo" "https://github.com/forgejo/forgejo.git" "/opt/forgejo" $'services:\n  forgejo:\n    image: codeberg.org/forgejo/forgejo:10\n    ports:\n      - "3005:3000"\n      - "2222:22"\n    restart: unless-stopped\n    volumes:\n      - ./data:/data'
