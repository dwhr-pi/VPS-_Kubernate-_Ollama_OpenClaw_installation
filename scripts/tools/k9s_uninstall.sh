#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
begin_measurement tool_uninstall_K9s 'K9s Release-Binary entfernen'
if ! sudo rm -f -- /usr/local/bin/k9s; then
  end_measurement failed
  exit 1
fi
mark_tool_removed K9s
log_info 'Setup-Binary entfernt. K9s-Konfiguration und kubeconfig bleiben erhalten.'
end_measurement success
