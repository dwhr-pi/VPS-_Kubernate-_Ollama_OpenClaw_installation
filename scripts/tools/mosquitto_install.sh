#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Mosquitto" "https://github.com/eclipse-mosquitto/mosquitto.git" "/opt/mosquitto" $'services:\n  mosquitto:\n    image: eclipse-mosquitto:2\n    ports:\n      - "1883:1883"\n      - "9001:9001"\n    restart: unless-stopped\n    volumes:\n      - ./config:/mosquitto/config\n      - ./data:/mosquitto/data\n      - ./log:/mosquitto/log'
