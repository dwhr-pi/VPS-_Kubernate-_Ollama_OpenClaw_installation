#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Legal_Compliance_Safety_Review" "Profil deinstallieren: Legal Compliance Safety Review"
mark_profile_removed "Legal_Compliance_Safety_Review"
end_measurement "success"
