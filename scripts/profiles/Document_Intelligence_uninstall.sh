#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in pandoc pdf_parser docling apache_tika ocrmypdf stirling_pdf paperless_ngx; do bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" || true; done
mark_profile_removed "Document_Intelligence"
