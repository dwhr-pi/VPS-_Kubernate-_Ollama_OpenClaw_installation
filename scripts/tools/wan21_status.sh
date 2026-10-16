#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/wan21_common.sh"
wan21_main status
