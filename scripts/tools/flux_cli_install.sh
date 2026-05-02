#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Flux_CLI" "Tool installieren: Flux CLI"
curl -fsSL https://fluxcd.io/install.sh | sudo bash
mark_tool_installed "Flux_CLI"
end_measurement "success"
