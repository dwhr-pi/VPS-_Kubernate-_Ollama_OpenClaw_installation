#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Joplin_CLI" "Tool deinstallieren: Joplin CLI"
sudo npm uninstall -g joplin || true
mark_tool_removed "Joplin_CLI"
end_measurement "success"
