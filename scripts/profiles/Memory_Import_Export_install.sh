#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

TOOLS=(qdrant chromadb duckdb docling apache_tika open_webui)

for s in "${TOOLS[@]}"; do
  script="$ROOT_DIR/scripts/tools/${s}_install.sh"
  if [ ! -f "$script" ]; then
    echo "Fehler: erwartetes Tool-Installationsskript fehlt: $script" >&2
    exit 1
  fi
  bash "$script"
done

mkdir -p "$HOME/.openclaw_ultimate_user_data/imports" "$HOME/.openclaw_ultimate_user_data/exports" "$HOME/.openclaw_ultimate_user_data/memory"
mark_profile_installed "Memory_Import_Export"
