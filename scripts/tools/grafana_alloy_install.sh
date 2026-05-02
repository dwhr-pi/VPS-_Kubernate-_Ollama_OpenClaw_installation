#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_git_docker_tool "Grafana_Alloy" "https://github.com/grafana/alloy.git" "/opt/grafana-alloy" $'services:\n  alloy:\n    image: grafana/alloy:latest\n    container_name: grafana-alloy\n    restart: unless-stopped\n    network_mode: host\n'
