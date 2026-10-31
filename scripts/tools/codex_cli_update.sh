#!/usr/bin/env bash
# Source: https://github.com/openai/codex.git
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 -I -B "${script_dir}/../agents/install_cli.py" codex_cli update "$@"
