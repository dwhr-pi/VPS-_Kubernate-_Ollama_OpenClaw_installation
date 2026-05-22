#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"

begin_measurement "tool_install_Docker_Compose_Plugin" "Tool installieren: Docker Compose Plugin"
if ensure_docker_compose_available; then
  mark_tool_installed "Docker_Compose_Plugin"
  log_success "Docker Compose Plugin installiert/verfuegbar: $(docker compose version 2>/dev/null || true)"
  end_measurement "success"
else
  log_error "Docker Compose Plugin konnte nicht bereitgestellt werden."
  end_measurement "failed"
  exit 1
fi
