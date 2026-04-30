#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Zigbee2MQTT" "https://github.com/Koenkk/zigbee2mqtt.git" "/opt/zigbee2mqtt" $'services:\n  zigbee2mqtt:\n    image: koenkk/zigbee2mqtt:latest\n    restart: unless-stopped\n    ports:\n      - "8099:8080"\n    volumes:\n      - ./data:/app/data\n    environment:\n      TZ: Europe/Berlin'
