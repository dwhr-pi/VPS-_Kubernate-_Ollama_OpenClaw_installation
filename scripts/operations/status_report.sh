#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

ensure_user_workspace
echo "=== Installierte Profile ==="
cat "$PROFILE_STATUS_FILE" 2>/dev/null || true
echo
echo "=== Installierte Tools ==="
cat "$TOOL_STATUS_FILE" 2>/dev/null || true
echo
echo "=== Logs ==="
ls -1 "$USER_LOG_DIR" 2>/dev/null || true
