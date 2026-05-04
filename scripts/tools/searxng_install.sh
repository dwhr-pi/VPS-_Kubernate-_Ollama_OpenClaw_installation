#!/bin/bash
set -euo pipefail
TOOL_NAME="SearXNG"
TOOL_KEY="SearXNG"
TOOL_SLUG="searxng"
COMPOSE_YAML='services:
  redis:
    image: docker.io/valkey/valkey:8-alpine
    container_name: searxng_valkey
    restart: unless-stopped
  searxng:
    image: docker.io/searxng/searxng:latest
    container_name: searxng
    restart: unless-stopped
    ports:
      - "127.0.0.1:8888:8080"
    environment:
      - SEARXNG_BASE_URL=http://127.0.0.1:8888/
    volumes:
      - ./config:/etc/searxng
    depends_on:
      - redis
'
TOOL_DESCRIPTION="Privacy-orientierte Meta-Suchmaschine für lokale Recherche, OSINT und Quellenvergleich."
TOOL_PROMPT_EXAMPLE='Sichere lokale Web-Recherche mit eigener Metasuche statt direkter Abhängigkeit von einem einzelnen Provider.'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
