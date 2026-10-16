#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/qwen_desktop_common.sh"
qwen_desktop_main "${1:-install}"
