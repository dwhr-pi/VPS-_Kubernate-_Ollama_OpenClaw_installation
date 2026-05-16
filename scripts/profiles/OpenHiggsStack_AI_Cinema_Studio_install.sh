#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

echo "Installiere Profil: OpenHiggsStack AI Cinema Studio"
echo "Hinweis: Es werden keine grossen Video-/Bildmodelle automatisch heruntergeladen."

bash "$ROOT_DIR/scripts/install-openhiggsstack.sh"

mark_profile_installed "OpenHiggsStack_AI_Cinema_Studio"

