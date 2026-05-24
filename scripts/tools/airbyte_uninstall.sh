#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="Airbyte"
INSTALL_ROOT="/opt/airbyte"
ABCTL_BIN="$INSTALL_ROOT/bin/abctl"

begin_measurement "tool_uninstall_${TOOL_NAME}" "Tool deinstallieren: ${TOOL_NAME}"

if [ -x "$ABCTL_BIN" ]; then
  log_warn "Deinstalliere Airbyte ueber abctl. Persistente Daten werden standardmaessig behalten."
  if docker info >/dev/null 2>&1; then
    "$ABCTL_BIN" local uninstall || true
  else
    sudo "$ABCTL_BIN" local uninstall || true
  fi
else
  log_warn "abctl wurde nicht unter $ABCTL_BIN gefunden. Entferne nur lokale Quellen/Wrapper."
fi

rm -rf "$INSTALL_ROOT"
mark_tool_removed "$TOOL_NAME"
log_success "Airbyte wurde entfernt. Falls abctl persistente Docker/Kubernetes-Daten behalten hat, pruefe bei Bedarf 'docker ps -a' und 'docker volume ls'."
end_measurement "success"
