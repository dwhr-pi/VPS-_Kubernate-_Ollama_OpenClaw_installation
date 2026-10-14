#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/audio_review_candidate_common.sh"
audio_review_candidate_main status
