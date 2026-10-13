#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
begin_measurement tool_uninstall_Syft 'Syft Release-Binary entfernen'
if ! sudo rm -f -- /usr/local/bin/syft; then
  end_measurement failed
  exit 1
fi
mark_tool_removed Syft
log_info 'Setup-Binary entfernt. SBOM-Dateien und Konfiguration bleiben erhalten.'
end_measurement success
