#!/usr/bin/env bash
# Quelle: https://github.com/dgtlmoon/changedetection.io; siehe docs/DOCKER_TO_GITHUB.md.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${NATIVE_GITHUB_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/native_github_tools.py" changedetection_io uninstall "$@"
