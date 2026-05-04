#!/bin/bash
set -euo pipefail
TOOL_NAME="changedetection.io"
TOOL_KEY="Changedetection_IO"
TOOL_SLUG="changedetection_io"
COMPOSE_YAML='services:
  changedetection:
    image: lscr.io/linuxserver/changedetection.io:latest
    container_name: changedetection_io
    restart: unless-stopped
    ports:
      - "127.0.0.1:5000:5000"
    volumes:
      - ./data:/config
'
TOOL_DESCRIPTION="Self-Hosted Web-Monitoring für Änderungen, Watchlists und sichere Beobachtung externer Seiten."
TOOL_PROMPT_EXAMPLE='Änderungen an Zielseiten überwachen und nur intern auf localhost bereitstellen.'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
