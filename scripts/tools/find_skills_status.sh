#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${FIND_SKILLS_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/find_skills.py" status "$@"
