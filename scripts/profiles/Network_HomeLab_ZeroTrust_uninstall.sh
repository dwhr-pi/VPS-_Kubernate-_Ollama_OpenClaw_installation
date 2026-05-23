#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Network_HomeLab_ZeroTrust" "Profil deinstallieren: Network HomeLab ZeroTrust"
mark_profile_removed "Network_HomeLab_ZeroTrust"
end_measurement "success"
