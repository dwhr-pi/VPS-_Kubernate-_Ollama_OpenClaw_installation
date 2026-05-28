#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "n8n Git/Source-Build ist schwer und bleibt opt-in. Siehe docs/N8N_GIT_INSTALL.md"
exec bash "$ROOT_DIR/scripts/tools/n8n_install.sh" "$@"
