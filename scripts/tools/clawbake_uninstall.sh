#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -P "${BASH_SOURCE[0]%/*}/../.." && pwd)"
HELPER="$ROOT/scripts/security/legacy_core_uninstall.py"
[[ -f "$HELPER" && ! -L "$HELPER" ]] || exit 1
exec python3 -I -B "$HELPER" clawbake "$@"
