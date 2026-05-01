#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in open_webui qdrant chromadb jupyterlab docling paperless_ngx; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Education_Tutor"
