#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/audiogen_common.sh"
audiogen_main "${1:-uninstall}"
