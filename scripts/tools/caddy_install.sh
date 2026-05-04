#!/bin/bash
set -euo pipefail
TOOL_NAME="Caddy"
TOOL_KEY="Caddy"
TOOL_SLUG="caddy"
COMPOSE_YAML='services:
  caddy:
    image: caddy:2-alpine
    container_name: caddy
    restart: unless-stopped
    ports:
      - "127.0.0.1:8086:80"
      - "127.0.0.1:2019:2019"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./data:/data
      - ./config:/config
'
TOOL_DESCRIPTION="Reverse Proxy für lokale Dienste mit sauberer Kante zwischen internen Services und bewusster Freigabe."
TOOL_PROMPT_EXAMPLE='Caddy als lokale Reverse-Proxy-Schicht vor UIs und Agenten-Diensten nur mit expliziter Freigabe konfigurieren.'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
