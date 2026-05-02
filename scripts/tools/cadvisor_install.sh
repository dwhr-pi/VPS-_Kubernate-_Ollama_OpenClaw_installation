#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_git_docker_tool "cAdvisor" "https://github.com/google/cadvisor.git" "/opt/cadvisor" $'services:\n  cadvisor:\n    image: gcr.io/cadvisor/cadvisor:latest\n    container_name: cadvisor\n    restart: unless-stopped\n    ports:\n      - \"8088:8080\"\n    volumes:\n      - /:/rootfs:ro\n      - /var/run:/var/run:ro\n      - /sys:/sys:ro\n      - /var/lib/docker/:/var/lib/docker:ro\n'
