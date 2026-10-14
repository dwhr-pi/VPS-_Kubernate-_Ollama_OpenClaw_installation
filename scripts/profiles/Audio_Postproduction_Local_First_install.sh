#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../tools" && pwd)/helpers/media_candidate_common.sh"
media_candidate_main "${1:-install}"
