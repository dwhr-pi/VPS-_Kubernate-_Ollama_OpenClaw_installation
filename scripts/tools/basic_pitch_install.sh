#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/basic_pitch_common.sh"
basic_pitch_main "${1:-install}"
