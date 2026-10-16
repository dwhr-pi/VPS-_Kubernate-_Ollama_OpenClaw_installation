#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/deepfilternet_common.sh"
deepfilternet_main "${1:-check}"
