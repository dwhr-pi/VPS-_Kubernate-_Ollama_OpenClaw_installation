#!/bin/bash
TOOL_NAME="Uptime_Kuma"
TOOL_KEY="Uptime_Kuma"
TOOL_SLUG="uptime_kuma"
TOOL_GIT_REPO="https://github.com/louislam/uptime-kuma.git"
COMPOSE_YAML='services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "3004:3001"
    volumes:
      - ./data:/app/data'
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
install_github_docker_stack_tool
