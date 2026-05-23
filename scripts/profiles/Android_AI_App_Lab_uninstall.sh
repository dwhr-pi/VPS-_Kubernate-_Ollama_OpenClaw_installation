#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Android_AI_App_Lab" "Profil deinstallieren: Android AI App Lab"
mark_profile_removed "Android_AI_App_Lab"
end_measurement "success"
