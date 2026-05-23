#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Data_Scraping_Browser_Agents" "Profil deinstallieren: Data Scraping Browser Agents"
mark_profile_removed "Data_Scraping_Browser_Agents"
end_measurement "success"
