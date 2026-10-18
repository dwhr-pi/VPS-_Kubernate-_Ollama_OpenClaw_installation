#!/usr/bin/env bash
set -euo pipefail
HIL_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$HIL_REPO_ROOT/scripts/tools/helpers/embedded_debug_hil_source.sh"
