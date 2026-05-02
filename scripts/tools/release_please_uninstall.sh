#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Release_Please" "Tool deinstallieren: Release Please"
sudo npm uninstall -g release-please || true
mark_tool_removed "Release_Please"
end_measurement "success"
