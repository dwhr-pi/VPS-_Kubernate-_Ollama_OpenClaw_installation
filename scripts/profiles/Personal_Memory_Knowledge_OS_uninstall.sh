#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Personal_Memory_Knowledge_OS" "Profil deinstallieren: Personal Memory Knowledge OS"
mark_profile_removed "Personal_Memory_Knowledge_OS"
end_measurement "success"
