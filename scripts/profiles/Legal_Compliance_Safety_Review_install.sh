#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Legal_Compliance_Safety_Review" "Profil installieren: Legal Compliance Safety Review"
echo "Profil ist aktuell als planned/documentation-first registriert. Es ersetzt keine Rechtsberatung."
mark_profile_installed "Legal_Compliance_Safety_Review"
end_measurement "success"
