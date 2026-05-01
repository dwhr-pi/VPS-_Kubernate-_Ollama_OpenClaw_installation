#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Healthchecks" "https://github.com/healthchecks/healthchecks.git" "/opt/healthchecks" $'services:\n  db:\n    image: postgres:16\n    restart: unless-stopped\n    environment:\n      POSTGRES_DB: healthchecks\n      POSTGRES_USER: healthchecks\n      POSTGRES_PASSWORD: healthchecks\n  web:\n    image: lscr.io/linuxserver/healthchecks:latest\n    restart: unless-stopped\n    ports:\n      - "8004:8000"\n    depends_on:\n      - db'
