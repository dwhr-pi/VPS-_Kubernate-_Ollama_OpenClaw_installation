#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_git_docker_tool "Meilisearch" "https://github.com/meilisearch/meilisearch.git" "/opt/meilisearch" $'services:\n  meilisearch:\n    image: getmeili/meilisearch:latest\n    container_name: meilisearch\n    restart: unless-stopped\n    ports:\n      - \"7700:7700\"\n'
