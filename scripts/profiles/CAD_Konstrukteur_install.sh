#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

bash "$REPO_ROOT/scripts/tools/cad_konstrukteur_install.sh"
bash "$REPO_ROOT/scripts/check/check_cad_tools.sh" || true
