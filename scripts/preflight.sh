#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Reuse the bounded diagnostics contract; offline is intentionally incomplete (exit 3).
exec python3 -I -B "$ROOT_DIR/scripts/operations/platform_health.py" doctor "$@"
