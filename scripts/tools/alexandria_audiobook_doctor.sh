#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/alexandria_audiobook_common.sh"
alexandria_audiobook_main "${1:-doctor}"
