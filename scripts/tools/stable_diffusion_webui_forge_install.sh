#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
install_git_python_tool "Stable_Diffusion_WebUI_Forge" "https://github.com/lllyasviel/stable-diffusion-webui-forge.git" "/opt/stable_diffusion_webui_forge"
