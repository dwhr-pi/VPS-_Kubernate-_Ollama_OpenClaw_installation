#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in openclaw litellm langfuse promptfoo qdrant openlit; do [ -f "$ROOT_DIR/scripts/tools/${s}_install.sh" ] && bash "$ROOT_DIR/scripts/tools/${s}_install.sh"; done
mkdir -p "$HOME/.openclaw_ultimate_user_data/profiles/self-learning-agent-lab/replay_logs"
mark_profile_installed "Self_Learning_Agent_Lab"
