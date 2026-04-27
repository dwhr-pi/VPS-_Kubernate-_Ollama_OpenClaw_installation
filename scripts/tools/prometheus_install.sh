#!/bin/bash
TOOL_NAME="Prometheus"
TOOL_KEY="Prometheus"
TOOL_SLUG="prometheus"
COMPOSE_YAML='services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./data:/prometheus'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
TOOL_ENV_FILE_CONTENT=''
install_docker_compose_tool
