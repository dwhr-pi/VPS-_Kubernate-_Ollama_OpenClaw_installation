#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/whisperx_common.sh"
whisperx_main "${1:-doctor}"
