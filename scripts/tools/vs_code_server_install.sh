#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
init_tool_tracking "VS_Code_Server"
curl -fsSL https://code-server.dev/install.sh | sh
mark_current_tool_installed
echo "VS Code Server wurde erfolgreich installiert."
