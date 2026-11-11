#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 -I -B "$ROOT_DIR/scripts/operations/platform_health.py" smoke "$@"
