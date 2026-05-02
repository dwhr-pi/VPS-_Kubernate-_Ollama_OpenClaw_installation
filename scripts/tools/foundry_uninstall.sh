#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Foundry" "Tool deinstallieren: Foundry"
rm -rf "$HOME/.foundry"
mark_tool_removed "Foundry"
end_measurement "success"
