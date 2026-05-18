#!/usr/bin/env bash
# Tool-Wrapper: Ruflo aus dem normalen Tool-Management installieren.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

exec bash "$REPO_DIR/scripts/ruflo_install.sh"
