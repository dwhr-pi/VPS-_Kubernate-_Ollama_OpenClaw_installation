#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
echo "Defensive Security-Tools werden nicht automatisch entfernt; Profil-Markierung wird entfernt."
mark_profile_removed "Cyber_Security_AI"
