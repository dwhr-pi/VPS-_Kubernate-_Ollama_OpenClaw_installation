#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
init_tool_tracking "K3s"
curl -sfL https://get.k3s.io | sh -
mark_current_tool_installed
echo "K3s wurde erfolgreich installiert."
