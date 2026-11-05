#!/usr/bin/env bash
# Pinned GitHub audio tool; no GUI, models, inference, services or Docker.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${NATIVE_GITHUB_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/native_github_tools.py" ffmpeg status "$@"
