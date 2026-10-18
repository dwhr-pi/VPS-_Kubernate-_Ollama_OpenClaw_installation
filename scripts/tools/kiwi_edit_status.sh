#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/kiwi_edit_common.sh"
kiwi_edit_main "${1:-status}"
