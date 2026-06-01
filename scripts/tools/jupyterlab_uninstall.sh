#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

INSTALL_DIR="${JUPYTERLAB_DIR:-/opt/jupyterlab}"
BIN_LINK="${JUPYTERLAB_BIN:-/usr/local/bin/jupyter-lab-openclaw}"

begin_measurement "tool_uninstall_JupyterLab" "Tool deinstallieren: JupyterLab"
sudo rm -f "$BIN_LINK"
rm -rf "$INSTALL_DIR"
mark_tool_removed "JupyterLab"
log_success "JupyterLab entfernt."
end_measurement "success"

