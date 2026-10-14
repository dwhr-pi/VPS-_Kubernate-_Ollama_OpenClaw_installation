#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/freellmapi_common.sh"
freellmapi_main "${1:-install}"
