#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/audioseal_common.sh"
audioseal_main "${1:-status}"
