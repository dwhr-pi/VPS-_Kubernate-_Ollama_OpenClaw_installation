#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/embedded_debug_hil_common.sh"
hil_main "${1:-update}"
