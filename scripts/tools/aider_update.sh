#!/usr/bin/env bash
# Source: https://github.com/Aider-AI/aider.git
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 -I -B "${script_dir}/../agents/install_cli.py" aider update "$@"
