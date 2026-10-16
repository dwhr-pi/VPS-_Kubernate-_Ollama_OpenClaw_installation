#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/fal_client_common.sh"
fal_client_main "${1:-uninstall}"
