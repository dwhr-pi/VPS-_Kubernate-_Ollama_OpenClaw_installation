#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/tools/helpers/simple_tool_common.sh"
install_git_python_tool "Web3_Py" "https://github.com/ethereum/web3.py.git" "/opt/web3-py" ""
