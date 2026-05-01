#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in qdrant chromadb langchain llamaindex; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Personal_Knowledge_Memory"
