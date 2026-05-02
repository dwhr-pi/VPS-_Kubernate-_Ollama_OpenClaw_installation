#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Changelog_Generator" "Tool installieren: Changelog Generator"
sudo npm install -g conventional-changelog-cli
mark_tool_installed "Changelog_Generator"
end_measurement "success"
