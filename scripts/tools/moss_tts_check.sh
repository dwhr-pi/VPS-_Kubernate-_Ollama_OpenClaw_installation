#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/moss_tts_common.sh"
moss_tts_main "${1:-check}"
