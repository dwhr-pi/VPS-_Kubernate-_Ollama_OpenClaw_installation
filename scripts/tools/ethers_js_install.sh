#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Ethers_JS" "Tool installieren: Ethers.js"
sudo npm install -g ethers
mark_tool_installed "Ethers_JS"
end_measurement "success"
