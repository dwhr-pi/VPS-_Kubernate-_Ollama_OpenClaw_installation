#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
echo "Dashboards bleiben als Benutzerartefakte erhalten."
mark_profile_removed "AI_Dashboard_Builder"
