#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/social_media_candidate_common.sh"
social_media_candidate_main "${1:-install}"
