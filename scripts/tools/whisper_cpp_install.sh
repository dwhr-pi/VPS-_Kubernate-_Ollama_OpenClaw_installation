#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_node_tool "Whisper_CPP" "https://github.com/ggml-org/whisper.cpp.git" "/opt/whisper_cpp" "make -j$(nproc)"
