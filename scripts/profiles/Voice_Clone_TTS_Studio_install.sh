#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in piper coqui_tts whisper_cpp faster_whisper ffmpeg pydub; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Voice_Clone_TTS_Studio"
