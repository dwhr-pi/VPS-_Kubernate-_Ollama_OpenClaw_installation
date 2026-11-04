#!/usr/bin/env bash
# Legacy implementation: docs/legacy/VPS_STANDALONE_REFERENCE.sh.txt (not executable).
# Keep the existing entrypoint and reviewed core contract; no legacy host changes.
set -Eeuo pipefail
CORE_ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$CORE_ROOT/scripts/tools/k3s_install.sh" "$@"
