#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Local_AI_Office_Suite" "Profil installieren: Local AI Office Suite"
echo "Profil ist aktuell als planned/documentation-first registriert. Installiere Tools einzeln nach Freigabe."
mark_profile_installed "Local_AI_Office_Suite"
end_measurement "success"
