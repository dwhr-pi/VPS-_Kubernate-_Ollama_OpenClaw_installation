#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Data_Scraping_Browser_Agents" "Profil installieren: Data Scraping Browser Agents"
echo "Profil ist aktuell als planned/documentation-first registriert. Crawler werden nicht automatisch gestartet."
mark_profile_installed "Data_Scraping_Browser_Agents"
end_measurement "success"
