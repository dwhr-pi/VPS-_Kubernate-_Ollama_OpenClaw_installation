#!/usr/bin/env bash
# Legacy installs have no trustworthy ownership receipt; never infer deletion rights.
set -Eeuo pipefail
ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
HELPER="$ROOT/scripts/security/legacy_core_uninstall.py"
[[ -f "$HELPER" && ! -L "$HELPER" ]] || {
  printf 'OpenClaw: Uninstall-Guard fehlt; nichts geaendert.\n' >&2
  exit 1
}
exec python3 -I -B "$HELPER" openclaw "$@"
