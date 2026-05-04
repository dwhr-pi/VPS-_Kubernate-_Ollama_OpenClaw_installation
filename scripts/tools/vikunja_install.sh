#!/bin/bash
set -euo pipefail
TOOL_NAME="Vikunja"
TOOL_KEY="Vikunja"
TOOL_SLUG="vikunja"
COMPOSE_YAML='services:
  vikunja:
    image: vikunja/vikunja:latest
    container_name: vikunja
    restart: unless-stopped
    ports:
      - "127.0.0.1:3456:3456"
    environment:
      VIKUNJA_SERVICE_JWTSECRET: change-me-locally
      VIKUNJA_SERVICE_ENABLEREGISTRATION: "false"
      VIKUNJA_DATABASE_PATH: /db/vikunja.db
    volumes:
      - ./db:/db
      - ./files:/app/vikunja/files
'
TOOL_DESCRIPTION="Self-Hosted Aufgaben- und Projektmanagement für lokale Agenten-, Office- und Workflow-Steuerung."
TOOL_PROMPT_EXAMPLE='Vikunja lokal als Aufgaben-Backlog für Office- und Agenten-Workflows vorbereiten.'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
