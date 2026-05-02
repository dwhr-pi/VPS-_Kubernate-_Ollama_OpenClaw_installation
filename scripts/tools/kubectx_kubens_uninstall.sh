#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Kubectx_Kubens" "Tool deinstallieren: kubectx/kubens"
sudo rm -f /usr/local/bin/kubectx /usr/local/bin/kubens
rm -rf /opt/kubectx
mark_tool_removed "Kubectx_Kubens"
end_measurement "success"
