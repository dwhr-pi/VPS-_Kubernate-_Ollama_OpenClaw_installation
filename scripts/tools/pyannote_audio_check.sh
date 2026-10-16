#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/pyannote_audio_common.sh"
pyannote_audio_main check
