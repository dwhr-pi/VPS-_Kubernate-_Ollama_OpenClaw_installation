#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/stable_audio_open_common.sh"
stable_audio_open_main "${1:-check}"
