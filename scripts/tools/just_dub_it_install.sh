#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/just_dub_it_common.sh"
just_dub_it_main "${1:-install}"
