#!/bin/bash
TOOL_NAME="Grafana"
TOOL_KEY="Grafana"
TOOL_SLUG="grafana"
COMPOSE_YAML='services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3001:3000"
    volumes:
      - ./data:/var/lib/grafana'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
