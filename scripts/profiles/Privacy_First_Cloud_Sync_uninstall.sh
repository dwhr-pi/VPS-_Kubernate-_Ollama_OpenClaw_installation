#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Privacy_First_Cloud_Sync" "Profil deinstallieren: Privacy First Cloud Sync"
mark_profile_removed "Privacy_First_Cloud_Sync"
end_measurement "success"
