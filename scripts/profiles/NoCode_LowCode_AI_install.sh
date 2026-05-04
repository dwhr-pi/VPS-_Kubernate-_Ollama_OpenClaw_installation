#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in n8n activepieces node_red flowise langflow; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "NoCode_LowCode_AI"
