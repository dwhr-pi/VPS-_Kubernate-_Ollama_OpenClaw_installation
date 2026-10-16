#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/qwen3_tts_common.sh"
qwen3_tts_main "${1:-check}"
