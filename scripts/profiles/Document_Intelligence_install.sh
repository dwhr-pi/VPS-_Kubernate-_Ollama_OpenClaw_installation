#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in paperless_ngx stirling_pdf ocrmypdf apache_tika docling pdf_parser pandoc; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Document_Intelligence"
