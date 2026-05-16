#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in qdrant chromadb duckdb docling apache_tika open_webui; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mkdir -p "$HOME/.openclaw_ultimate_user_data/imports" "$HOME/.openclaw_ultimate_user_data/exports" "$HOME/.openclaw_ultimate_user_data/memory"
mark_profile_installed "Memory_Import_Export"
