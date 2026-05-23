#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Knowledge_Librarian" "Knowledge Librarian" "paperless_ngx docling apache_tika qdrant meilisearch pandoc"
