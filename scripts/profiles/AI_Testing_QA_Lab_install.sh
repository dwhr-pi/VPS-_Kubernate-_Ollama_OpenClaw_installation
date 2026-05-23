#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_AI_Testing_QA_Lab" "Profil installieren: AI Testing QA Lab"
echo "Profil ist aktuell als planned/documentation-first registriert. QA-Tools einzeln installieren."
mark_profile_installed "AI_Testing_QA_Lab"
end_measurement "success"
