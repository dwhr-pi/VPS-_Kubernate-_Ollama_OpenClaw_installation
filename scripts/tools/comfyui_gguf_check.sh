#!/usr/bin/env bash
set -euo pipefail
source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/helpers/comfyui_gguf_common.sh"
comfyui_gguf_main check
