#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Directus" "https://github.com/directus/directus.git" "/opt/directus" $'services:\n  directus:\n    image: directus/directus:latest\n    restart: unless-stopped\n    ports:\n      - "8055:8055"'
