#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Velero" "Tool deinstallieren: Velero"
sudo rm -f /usr/local/bin/velero
mark_tool_removed "Velero"
end_measurement "success"
