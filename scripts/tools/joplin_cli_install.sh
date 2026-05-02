#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Joplin_CLI" "Tool installieren: Joplin CLI"
sudo npm install -g joplin
mark_tool_installed "Joplin_CLI"
end_measurement "success"
