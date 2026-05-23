#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Astronomie_Space_AI" "Astronomie Space AI" "ollama openclaw jupyterlab docling"
