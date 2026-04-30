#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_docker_tool "Node_Exporter" "https://github.com/prometheus/node_exporter.git" "/opt/node_exporter" $'services:\n  node-exporter:\n    image: prom/node-exporter:latest\n    network_mode: host\n    restart: unless-stopped\n    pid: host\n    volumes:\n      - /:/host:ro,rslave\n    command:\n      - --path.rootfs=/host'
