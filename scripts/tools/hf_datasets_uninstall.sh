#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/hf_datasets_common.sh"
hf_datasets_main "${1:-uninstall}"
