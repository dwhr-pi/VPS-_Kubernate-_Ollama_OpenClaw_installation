#!/usr/bin/env bash
# Official source: https://github.com/browseros-ai/BrowserOS
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/browser_desktop_common.sh"
browser_desktop_main browseros "${1:-install}"
