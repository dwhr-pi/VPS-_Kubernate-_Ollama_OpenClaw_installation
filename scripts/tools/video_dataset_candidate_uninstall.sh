#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/video_dataset_candidate_common.sh"
video_dataset_candidate_main "${1:-uninstall}"
