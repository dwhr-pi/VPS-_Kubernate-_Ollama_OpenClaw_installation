#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

PERSONA_WORKSPACE_DIR="${USER_WORKSPACE_DIR}/persona_system"

log_warn "Workspace-Dateien unter $PERSONA_WORKSPACE_DIR bleiben absichtlich erhalten, damit Persona- und Memory-Daten nicht stillschweigend geloescht werden."
mark_profile_removed "Next_Level_Persona_System"
log_success "Next_Level_Persona_System Profil aus dem Setup-Status entfernt."
