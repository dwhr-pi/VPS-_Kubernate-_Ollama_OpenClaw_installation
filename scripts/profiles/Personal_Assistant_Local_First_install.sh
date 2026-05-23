#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Personal_Assistant_Local_First" "Personal Assistant Local First" "ollama openclaw open_webui qdrant n8n paperless_ngx"
