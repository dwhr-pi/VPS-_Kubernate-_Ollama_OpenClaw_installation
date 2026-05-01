#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in llamaindex langchain chromadb qdrant; do bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" || true; done
mark_profile_removed "Personal_Knowledge_Memory"
