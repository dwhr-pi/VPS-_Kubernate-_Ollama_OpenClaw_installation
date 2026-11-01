#!/usr/bin/env bash
# A directory listing is not a restore test; default is a side-effect-free plan.
set -Eeuo pipefail
ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
exec python3 -I -B "$ROOT/scripts/operations/restore_drill.py" "$@"
