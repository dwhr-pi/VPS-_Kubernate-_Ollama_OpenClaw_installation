#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
init_tool_tracking "Docker"
echo "Installiere Docker Engine..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER" || true
mark_current_tool_installed
echo "Docker wurde erfolgreich installiert."
