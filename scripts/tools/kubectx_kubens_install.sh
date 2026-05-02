#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Kubectx_Kubens" "Tool installieren: kubectx/kubens"
sudo mkdir -p /opt/kubectx
sudo chown -R "$USER:$USER" /opt/kubectx
if [ ! -d /opt/kubectx/.git ]; then
  git clone https://github.com/ahmetb/kubectx.git /opt/kubectx
else
  git -C /opt/kubectx pull --ff-only || true
fi
sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
mark_tool_installed "Kubectx_Kubens"
end_measurement "success"
