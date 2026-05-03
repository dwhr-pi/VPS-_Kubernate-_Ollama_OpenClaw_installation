#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"
TOOL_NAME="Open_WebUI"
TOOL_KEY="Open_WebUI"
TOOL_SLUG="open_webui"
TOOL_GIT_REPO="$(get_custom_repo_url "OPEN_WEBUI" "https://github.com/open-webui/open-webui.git")"
COMPOSE_YAML='services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "3000:8080"
    volumes:
      - ./data:/app/backend/data'
TOOL_ENV_FILE_CONTENT='ENABLE_SIGNUP=false
OLLAMA_BASE_URL=http://host.docker.internal:11434
OPENAI_API_BASE_URL=http://host.docker.internal:4000/v1
OPENAI_API_KEY=change-me'
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
install_github_docker_stack_tool
