#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/cline_common.sh"
cline_main doctor
