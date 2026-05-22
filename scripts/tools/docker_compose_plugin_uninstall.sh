#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"

begin_measurement "tool_uninstall_Docker_Compose_Plugin" "Tool deinstallieren: Docker Compose Plugin"
sudo rm -f /usr/local/lib/docker/cli-plugins/docker-compose
sudo apt-get remove -y docker-compose-plugin 2>/dev/null || true
mark_tool_removed "Docker_Compose_Plugin"
log_success "Docker Compose Plugin entfernt, falls es durch das Setup installiert wurde."
end_measurement "success"
