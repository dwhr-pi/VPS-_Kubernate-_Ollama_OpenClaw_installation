#!/usr/bin/env bash
# Upstream: https://github.com/bwendell/gemini-desktop; manual desktop release only, never runs an EXE.
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/browser_desktop_common.sh"
browser_desktop_main gemini_desktop_bwendell "${1:-doctor}"
