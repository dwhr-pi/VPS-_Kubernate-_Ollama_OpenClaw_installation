#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in paperless_ngx stirling_pdf apache_tika pandoc nextcloud; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Email_Office_Automation"
