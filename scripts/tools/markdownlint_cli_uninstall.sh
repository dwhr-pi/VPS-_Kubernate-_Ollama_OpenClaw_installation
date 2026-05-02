#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Markdownlint_CLI" "Tool deinstallieren: Markdownlint CLI"
sudo npm uninstall -g markdownlint-cli || true
mark_tool_removed "Markdownlint_CLI"
end_measurement "success"
