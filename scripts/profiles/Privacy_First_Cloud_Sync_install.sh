#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Privacy_First_Cloud_Sync" "Profil installieren: Privacy First Cloud Sync"
echo "Profil ist aktuell als planned/documentation-first registriert. Cloud-/Sync-Tools einzeln installieren."
mark_profile_installed "Privacy_First_Cloud_Sync"
end_measurement "success"
