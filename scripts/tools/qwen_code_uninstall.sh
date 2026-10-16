#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/qwen_code_common.sh"
qwen_code_main "${1:-uninstall}"
