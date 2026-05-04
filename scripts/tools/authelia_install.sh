#!/bin/bash
set -euo pipefail
TOOL_NAME="Authelia"
TOOL_KEY="Authelia"
TOOL_SLUG="authelia"
COMPOSE_YAML='services:
  authelia:
    image: authelia/authelia:latest
    container_name: authelia
    restart: unless-stopped
    ports:
      - "127.0.0.1:9091:9091"
    volumes:
      - ./config:/config
'
TOOL_DESCRIPTION="Authentifizierungs- und Access-Gateway für geschützte Self-Hosted-Dienste."
TOOL_PROMPT_EXAMPLE='Authelia nur als vorgeschaltete Auth-Schicht vor bewusst freigegebenen Diensten nutzen.'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
