#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Hardhat" "Tool deinstallieren: Hardhat"
sudo npm uninstall -g hardhat || true
mark_tool_removed "Hardhat"
end_measurement "success"
