#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Markdownlint_CLI" "Tool installieren: Markdownlint CLI"
sudo npm install -g markdownlint-cli
mark_tool_installed "Markdownlint_CLI"
end_measurement "success"
