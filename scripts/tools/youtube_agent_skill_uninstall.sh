#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec "${YOUTUBE_AGENT_SKILL_PYTHON_BIN:-python3}" -B "$ROOT/scripts/tools/helpers/youtube_agent_skill.py" uninstall "$@"
