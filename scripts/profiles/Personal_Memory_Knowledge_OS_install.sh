#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Personal_Memory_Knowledge_OS" "Profil installieren: Personal Memory Knowledge OS"
echo "Profil ist aktuell als planned/documentation-first registriert. Memory-Importer bleiben bis zur Freigabe deaktiviert."
mark_profile_installed "Personal_Memory_Knowledge_OS"
end_measurement "success"
