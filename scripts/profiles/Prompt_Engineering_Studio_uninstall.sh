#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in open_webui openlit langfuse litellm promptfoo; do [ -f "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh"; done
mark_profile_removed "Prompt_Engineering_Studio"
