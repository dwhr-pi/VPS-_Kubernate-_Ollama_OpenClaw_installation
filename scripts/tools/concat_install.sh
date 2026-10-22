#!/usr/bin/env bash
# Primaerquelle: https://github.com/jub0t/Concat (geprueftes Release-AppImage).
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${MEDIA_EDITORS_INSTALLER_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/media_editors.py" concat install "$@"
