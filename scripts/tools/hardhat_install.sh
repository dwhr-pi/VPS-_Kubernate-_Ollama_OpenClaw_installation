#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Hardhat" "Tool installieren: Hardhat"
sudo npm install -g hardhat
mark_tool_installed "Hardhat"
end_measurement "success"
