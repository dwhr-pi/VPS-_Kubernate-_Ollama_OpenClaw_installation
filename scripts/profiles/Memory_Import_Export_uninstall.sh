#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
echo "Importe, Exporte und Memory-Dateien bleiben in ~/.openclaw_ultimate_user_data erhalten."
mark_profile_removed "Memory_Import_Export"
