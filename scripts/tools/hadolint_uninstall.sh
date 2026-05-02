#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Hadolint" "Tool deinstallieren: Hadolint"
sudo rm -f /usr/local/bin/hadolint
mark_tool_removed "Hadolint"
end_measurement "success"
