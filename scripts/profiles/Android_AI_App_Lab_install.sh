#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Android_AI_App_Lab" "Profil installieren: Android AI App Lab"
echo "Profil ist aktuell als planned/documentation-first registriert. Android SDK/ADB werden nicht automatisch installiert."
mark_profile_installed "Android_AI_App_Lab"
end_measurement "success"
