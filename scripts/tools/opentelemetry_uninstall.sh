#!/usr/bin/env bash
# Legacy containers and /opt configuration are deliberately preserved.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${NATIVE_GITHUB_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/native_github_tools.py" opentelemetry uninstall "$@"
