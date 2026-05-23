#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Local_AI_Office_Suite" "Profil deinstallieren: Local AI Office Suite"
mark_profile_removed "Local_AI_Office_Suite"
end_measurement "success"
