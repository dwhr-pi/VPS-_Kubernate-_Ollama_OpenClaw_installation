#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_OPA" "Tool deinstallieren: OPA"
sudo rm -f /usr/local/bin/opa
mark_tool_removed "OPA"
end_measurement "success"
