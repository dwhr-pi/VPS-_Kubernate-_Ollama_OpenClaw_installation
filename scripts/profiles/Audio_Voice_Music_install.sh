#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in ffmpeg whisper_cpp piper coqui_tts musicgen; do
  if [ "$s" = "coqui_tts" ]; then
    bash "$ROOT_DIR/scripts/tools/${s}_install.sh" || echo "Hinweis: Coqui_TTS ist optional/experimental und wurde uebersprungen. Piper bleibt der stabile lokale TTS-Pfad."
  else
    bash "$ROOT_DIR/scripts/tools/${s}_install.sh"
  fi
done
mark_profile_installed "Audio_Voice_Music"
