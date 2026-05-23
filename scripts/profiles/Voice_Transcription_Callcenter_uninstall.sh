#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "profile_uninstall_Voice_Transcription_Callcenter" "Profil deinstallieren: Voice Transcription Callcenter"
mark_profile_removed "Voice_Transcription_Callcenter"
end_measurement "success"
