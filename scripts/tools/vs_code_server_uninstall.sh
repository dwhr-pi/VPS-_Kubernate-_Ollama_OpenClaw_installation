#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
init_tool_tracking "VS_Code_Server"
sudo apt-get remove -y code-server || true
sudo apt-get autoremove -y || true
mark_current_tool_removed
echo "VS Code Server wurde entfernt."
