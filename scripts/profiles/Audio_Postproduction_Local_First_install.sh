#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../tools/helpers/media_candidate_common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../tools" && pwd)/helpers/media_candidate_common.sh"
media_candidate_main "${1:-install}"
