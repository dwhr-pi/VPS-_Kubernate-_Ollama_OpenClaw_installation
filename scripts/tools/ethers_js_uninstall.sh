#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Ethers_JS" "Tool deinstallieren: Ethers.js"
sudo npm uninstall -g ethers || true
mark_tool_removed "Ethers_JS"
end_measurement "success"
