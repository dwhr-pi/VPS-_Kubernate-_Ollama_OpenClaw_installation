#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/vidubb_common.sh"
vidubb_main "${1:-status}"
