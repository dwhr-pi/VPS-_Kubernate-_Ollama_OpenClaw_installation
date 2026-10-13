#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
begin_measurement tool_uninstall_Kubectl 'Kubectl Release-Binary entfernen'
if ! sudo rm -f -- /usr/local/bin/kubectl; then
  end_measurement failed
  exit 1
fi
mark_tool_removed Kubectl
log_info 'Setup-Binary entfernt. ~/.kube und anderweitig installierte kubectl-Versionen bleiben erhalten.'
end_measurement success
