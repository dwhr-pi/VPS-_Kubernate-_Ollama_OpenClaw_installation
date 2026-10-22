#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${WEBINAR_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/webinar_releases.py" listmonk doctor "$@"
