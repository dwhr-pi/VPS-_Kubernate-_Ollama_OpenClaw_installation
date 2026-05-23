#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Network_HomeLab_ZeroTrust" "Profil installieren: Network HomeLab ZeroTrust"
echo "Profil ist aktuell als planned/documentation-first registriert. Remote-Zugriff wird nicht automatisch geoeffnet."
mark_profile_installed "Network_HomeLab_ZeroTrust"
end_measurement "success"
