#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Hadolint" "Tool installieren: Hadolint"
sudo curl -fsSL -o /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64"
sudo chmod +x /usr/local/bin/hadolint
mark_tool_installed "Hadolint"
end_measurement "success"
