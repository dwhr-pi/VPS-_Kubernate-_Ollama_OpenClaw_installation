#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Voice_Command_Center" "Voice Command Center" "whisper_cpp faster_whisper piper coqui_tts home_assistant node_red"
