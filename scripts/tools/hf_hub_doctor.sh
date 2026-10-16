#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/hf_hub_common.sh"
hf_hub_main "${1:-doctor}"
