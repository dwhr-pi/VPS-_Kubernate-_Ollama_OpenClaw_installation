#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Model_Router_Cost_Control" "Profil deinstallieren: Model Router Cost Control"
mark_profile_removed "Model_Router_Cost_Control"
end_measurement "success"
