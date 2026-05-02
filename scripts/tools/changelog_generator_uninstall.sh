#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Changelog_Generator" "Tool deinstallieren: Changelog Generator"
sudo npm uninstall -g conventional-changelog-cli || true
mark_tool_removed "Changelog_Generator"
end_measurement "success"
