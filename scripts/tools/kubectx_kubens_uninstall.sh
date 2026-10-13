#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
uninstall_kubectx_kubens() {
  begin_measurement "tool_uninstall_Kubectx_Kubens" "Tool deinstallieren: kubectx/kubens"
  if [ -L /opt/kubectx ] || [ "$(realpath -m -- /opt/kubectx)" != /opt/kubectx ]; then
    log_error "Unsicheres Deinstallationsziel: /opt/kubectx verweist auf einen anderen Pfad."
    end_measurement "failed"
    return 1
  fi
  if ! sudo rm -f -- /usr/local/bin/kubectx /usr/local/bin/kubens ||
     ! sudo rm -rf --one-file-system -- /opt/kubectx; then
    log_error "kubectx/kubens konnte nicht entfernt werden. sudo-Rechte pruefen und Deinstallation erneut starten."
    end_measurement "failed"
    return 1
  fi
  mark_tool_removed "Kubectx_Kubens"
  end_measurement "success"
}

uninstall_kubectx_kubens
