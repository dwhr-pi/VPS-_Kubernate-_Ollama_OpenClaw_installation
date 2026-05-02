#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Release_Please" "Tool installieren: Release Please"
sudo npm install -g release-please
mark_tool_installed "Release_Please"
end_measurement "success"
