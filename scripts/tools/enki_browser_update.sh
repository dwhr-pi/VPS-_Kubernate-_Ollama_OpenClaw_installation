#!/usr/bin/env bash
# Official source: https://github.com/danilogiles/enki-browser
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/browser_desktop_common.sh"
browser_desktop_main enki_browser "${1:-update}"
