#!/usr/bin/env bash
# No mutable clone/pull, host-directory adoption, package hooks or status writes.
set -Eeuo pipefail
ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
HELPER="$ROOT/scripts/security/core_source_gate.py"
[[ -f "$HELPER" && ! -L "$HELPER" ]] || {
  printf 'OpenClaw: Quellenpruefung fehlt; nichts geaendert.\n' >&2
  exit 1
}
exec python3 -I -B "$HELPER" openclaw "$@"
