#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in langflow flowise node_red activepieces n8n; do [ -f "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh"; done
mark_profile_removed "NoCode_LowCode_AI"
