#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
echo "Profil-Daten bleiben unter ~/.openclaw_ultimate_user_data/profiles/prompt-generator-studio erhalten."
mark_profile_removed "Prompt_Generator_Studio"
