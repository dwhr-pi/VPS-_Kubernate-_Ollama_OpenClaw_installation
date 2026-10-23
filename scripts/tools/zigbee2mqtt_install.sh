#!/usr/bin/env bash
# Quelle: https://github.com/Koenkk/zigbee2mqtt; siehe docs/DOCKER_TO_GITHUB.md.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${NATIVE_GITHUB_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/native_github_tools.py" zigbee2mqtt install "$@"
