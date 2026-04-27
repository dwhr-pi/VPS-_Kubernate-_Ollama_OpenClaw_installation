#!/bin/bash
TOOL_NAME="Qdrant"
TOOL_KEY="Qdrant"
TOOL_SLUG="qdrant"
COMPOSE_YAML='services:
  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    restart: unless-stopped
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - ./data:/qdrant/storage'
TOOL_PROMPT_EXAMPLE='```txt
Lege eine Qdrant-Collection für Agenten-Memory an und entwirf Retrieval-Regeln für OpenClaw-Profile.
```'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
