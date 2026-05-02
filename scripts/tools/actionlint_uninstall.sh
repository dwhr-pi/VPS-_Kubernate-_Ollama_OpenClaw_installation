#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Actionlint" "Tool deinstallieren: Actionlint"
sudo rm -f /usr/local/bin/actionlint
mark_tool_removed "Actionlint"
end_measurement "success"
