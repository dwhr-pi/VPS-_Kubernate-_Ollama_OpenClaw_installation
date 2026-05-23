#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_install_Voice_Transcription_Callcenter" "Profil installieren: Voice Transcription Callcenter"
echo "Profil ist aktuell als planned/documentation-first registriert. STT/TTS-Tools einzeln installieren."
mark_profile_installed "Voice_Transcription_Callcenter"
end_measurement "success"
