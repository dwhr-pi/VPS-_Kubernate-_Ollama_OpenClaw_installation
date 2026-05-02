#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_ArgoCD_CLI" "Tool deinstallieren: ArgoCD CLI"
sudo rm -f /usr/local/bin/argocd
mark_tool_removed "ArgoCD_CLI"
end_measurement "success"
