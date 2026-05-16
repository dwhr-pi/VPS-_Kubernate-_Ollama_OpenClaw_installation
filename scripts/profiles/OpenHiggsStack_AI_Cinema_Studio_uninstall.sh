#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

echo "Entferne Profilstatus: OpenHiggsStack AI Cinema Studio"
echo "Hinweis: Lokale Modelle, Outputs und ComfyUI-Ordner werden nicht automatisch geloescht."
echo "Pruefe bei Bedarf manuell: ~/ai-stack und ~/.openclaw_ultimate_user_data/openhiggsstack"

mark_profile_removed "OpenHiggsStack_AI_Cinema_Studio"

