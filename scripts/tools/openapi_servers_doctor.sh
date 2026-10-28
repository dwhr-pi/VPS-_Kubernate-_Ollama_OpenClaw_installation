#!/usr/bin/env bash
# Primary source: https://github.com/open-webui/openapi-servers; time environment only, no service start.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/gap_tools.py" openapi_servers doctor "$@"
