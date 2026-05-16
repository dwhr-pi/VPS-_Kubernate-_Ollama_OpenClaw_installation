#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
echo "Replay-Logs bleiben zur Nachvollziehbarkeit erhalten."
mark_profile_removed "Self_Learning_Agent_Lab"
