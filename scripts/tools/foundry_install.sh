#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Foundry" "Tool installieren: Foundry"
curl -fsSL https://foundry.paradigm.xyz | bash
if [ -f "$HOME/.foundry/bin/foundryup" ]; then
  "$HOME/.foundry/bin/foundryup"
fi
mark_tool_installed "Foundry"
end_measurement "success"
