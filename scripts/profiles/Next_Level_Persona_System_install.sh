#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

bash "$ROOT_DIR/scripts/persona/install_persona_system.sh"
mark_profile_installed "Next_Level_Persona_System"
log_success "Next_Level_Persona_System Profil installiert."
