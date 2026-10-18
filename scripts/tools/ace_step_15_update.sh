#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/ace_step_15_common.sh"
ace_step_15_main "${1:-update}"
