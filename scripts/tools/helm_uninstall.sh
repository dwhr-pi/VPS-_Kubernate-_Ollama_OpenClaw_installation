#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

INSTALL_BIN="${HELM_INSTALL_BIN:-/usr/local/bin/helm}"

begin_measurement "tool_uninstall_Helm" "Tool deinstallieren: Helm"
sudo rm -f "$INSTALL_BIN"
mark_tool_removed "Helm"
log_success "Helm entfernt."
end_measurement "success"
