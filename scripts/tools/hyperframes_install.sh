#!/usr/bin/env bash
# Primaerquelle: https://github.com/heygen-com/hyperframes (gepinnt im Helper).
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${MEDIA_EDITORS_INSTALLER_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/media_editors.py" hyperframes install "$@"
