#!/usr/bin/env bash
set -euo pipefail

# Keep the existing host-inspection entrypoint; --dry-run performs no host query.
ROOT="$(cd -P "${BASH_SOURCE[0]%/*}/../.." && pwd)"
if (($# == 0)); then
  set -- --check-host
fi
exec python3 -I -B "$ROOT/scripts/security/listener_audit.py" "$@"
