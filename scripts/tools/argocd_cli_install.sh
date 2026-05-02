#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_ArgoCD_CLI" "Tool installieren: ArgoCD CLI"
sudo curl -fsSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
sudo chmod +x /usr/local/bin/argocd
mark_tool_installed "ArgoCD_CLI"
end_measurement "success"
