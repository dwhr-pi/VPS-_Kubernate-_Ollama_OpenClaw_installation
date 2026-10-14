#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/hybrid_media_candidate_common.sh"
hybrid_media_candidate_main "${1:-uninstall}"
