#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_OPA" "Tool installieren: OPA"
sudo curl -fsSL -o /usr/local/bin/opa "https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static"
sudo chmod +x /usr/local/bin/opa
mark_tool_installed "OPA"
end_measurement "success"
