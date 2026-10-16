#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/audioldm2_common.sh"
audioldm2_main "${1:-install}"
