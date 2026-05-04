#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in open_webui puppeteer playwright; do [ -f "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh"; done
mark_profile_removed "Browser_Automation_Agent"
