#!/bin/bash
set -euo pipefail
TOOL_NAME="ArchiveBox"
TOOL_KEY="ArchiveBox"
TOOL_SLUG="archivebox"
COMPOSE_YAML='services:
  archivebox:
    image: archivebox/archivebox:latest
    container_name: archivebox
    restart: unless-stopped
    ports:
      - "127.0.0.1:8000:8000"
    volumes:
      - ./data:/data
    command: server --quick-init 127.0.0.1:8000
'
TOOL_DESCRIPTION="Self-Hosted Archivierungsdienst für Webseiten, Snapshots und Recherche-Quellen."
TOOL_PROMPT_EXAMPLE='Lokale Quellen für sichere Recherche archivieren, ohne Inhalte in fremde Dienste hochzuladen.'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
