#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"
TOOL_NAME="LiteLLM"
TOOL_KEY="LiteLLM"
TOOL_SLUG="litellm"
TOOL_GIT_REPO="$(get_custom_repo_url "LITELLM" "https://github.com/BerriAI/litellm.git")"
COMPOSE_YAML='services:
  litellm:
    image: ghcr.io/berriai/litellm:main-latest
    container_name: litellm
    restart: unless-stopped
    env_file:
      - .env
    volumes:
      - ./config/litellm-config.yaml:/app/config.yaml:ro
    command: ["--config", "/app/config.yaml", "--port", "4000", "--num_workers", "1"]
    ports:
      - "4000:4000"'
TOOL_ENV_FILE_CONTENT='LITELLM_MASTER_KEY=change-me
GEMINI_API_KEY=
OPENAI_API_KEY=
OLLAMA_API_BASE=http://host.docker.internal:11434'
TOOL_CONFIG_PATH_1='config/litellm-config.yaml'
TOOL_CONFIG_CONTENT_1='model_list:
  - model_name: ollama-default
    litellm_params:
      model: ollama/llama3.2:3b
      api_base: ${OLLAMA_API_BASE}
  - model_name: gemini-fallback
    litellm_params:
      model: gemini/gemini-2.5-flash
      api_key: ${GEMINI_API_KEY}
  - model_name: openai-fallback
    litellm_params:
      model: gpt-4.1-mini
      api_key: ${OPENAI_API_KEY}
router_settings:
  routing_strategy: simple-shuffle
  fallbacks:
    - ollama-default: [gemini-fallback, openai-fallback]
general_settings:
  master_key: ${LITELLM_MASTER_KEY}'
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
install_github_docker_stack_tool
