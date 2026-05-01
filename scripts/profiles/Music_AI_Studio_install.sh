#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in demucs ffmpeg librosa pydub musicgen bpm_analyzer; do bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mark_profile_installed "Music_AI_Studio"
