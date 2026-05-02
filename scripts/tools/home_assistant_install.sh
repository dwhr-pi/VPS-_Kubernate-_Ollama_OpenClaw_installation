#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

confirm_heavy_install "Home_Assistant" "Home Assistant installiert Docker, zieht Container-Images und belegt dauerhaft Speicherplatz auf dem Host."
install_git_docker_tool "Home_Assistant" "https://github.com/home-assistant/core.git" "/opt/home_assistant" $'services:\n  home-assistant:\n    image: ghcr.io/home-assistant/home-assistant:stable\n    container_name: home-assistant\n    restart: unless-stopped\n    network_mode: host\n    environment:\n      - TZ=Europe/Berlin\n    volumes:\n      - ./config:/config'
