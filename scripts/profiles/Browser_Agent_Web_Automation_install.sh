#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in playwright browser_use firecrawl trafilatura archivebox changedetection_io searxng; do
  [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"
done
mark_profile_installed "Browser_Agent_Web_Automation"
