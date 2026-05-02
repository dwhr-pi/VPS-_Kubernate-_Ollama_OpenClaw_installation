#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_uninstall_Pgvector" "Tool deinstallieren: pgvector"
sudo apt-get remove -y postgresql-16-pgvector postgresql-15-pgvector || true
mark_tool_removed "Pgvector"
end_measurement "success"
