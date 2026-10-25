#!/usr/bin/env bash
# Official source: https://www.perplexity.ai/comet
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/browser_desktop_common.sh"
browser_desktop_main comet "${1:-uninstall}"
