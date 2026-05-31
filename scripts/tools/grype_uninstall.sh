#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

INSTALL_BIN="${GRYPE_INSTALL_BIN:-/usr/local/bin/grype}"

begin_measurement "tool_uninstall_Grype" "Tool deinstallieren: Grype"
sudo rm -f "$INSTALL_BIN"
mark_tool_removed "Grype"
log_success "Grype entfernt."
end_measurement "success"
