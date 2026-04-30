#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Nextcloud" "https://github.com/nextcloud/server.git" "/opt/nextcloud" $'services:\n  nextcloud:\n    image: nextcloud:latest\n    ports:\n      - "8082:80"\n    restart: unless-stopped\n    volumes:\n      - ./data:/var/www/html'
