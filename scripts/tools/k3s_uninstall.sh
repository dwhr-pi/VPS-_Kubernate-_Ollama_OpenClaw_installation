#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
init_tool_tracking "K3s"
sudo /usr/local/bin/k3s-uninstall.sh || true
mark_current_tool_removed
echo "K3s wurde entfernt."
