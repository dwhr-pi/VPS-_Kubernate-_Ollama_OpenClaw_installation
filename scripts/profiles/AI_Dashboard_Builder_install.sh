#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in grafana prometheus loki netdata appsmith budibase nocodb; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mkdir -p "$HOME/.openclaw_ultimate_user_data/profiles/ai-dashboard-builder"
mark_profile_installed "AI_Dashboard_Builder"
