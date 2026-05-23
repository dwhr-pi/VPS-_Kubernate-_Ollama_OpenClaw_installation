#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Medizinische_Literatur_Recherche" "Medizinische Literatur Recherche" "ollama openclaw docling apache_tika paperless_ngx qdrant"
