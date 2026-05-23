#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_AI_Testing_QA_Lab" "Profil deinstallieren: AI Testing QA Lab"
mark_profile_removed "AI_Testing_QA_Lab"
end_measurement "success"
