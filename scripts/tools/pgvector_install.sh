#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Pgvector" "Tool installieren: pgvector"
sudo apt-get update
sudo apt-get install -y postgresql || true
sudo apt-get install -y postgresql-16-pgvector || sudo apt-get install -y postgresql-15-pgvector || true
mark_tool_installed "Pgvector"
end_measurement "success"
