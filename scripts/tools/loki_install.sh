#!/bin/bash
TOOL_NAME="Loki"
TOOL_KEY="Loki"
TOOL_SLUG="loki"
COMPOSE_YAML='services:
  loki:
    image: grafana/loki:latest
    container_name: loki
    restart: unless-stopped
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
