#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Flux_CLI" "Tool deinstallieren: Flux CLI"
sudo rm -f /usr/local/bin/flux
mark_tool_removed "Flux_CLI"
end_measurement "success"
