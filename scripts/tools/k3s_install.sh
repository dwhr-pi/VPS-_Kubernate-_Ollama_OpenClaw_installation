#!/usr/bin/env bash
# Cluster installation requires a separately approved bootstrap contract.
set -Eeuo pipefail
ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
HELPER="$ROOT/scripts/security/core_source_gate.py"
[[ -f "$HELPER" && ! -L "$HELPER" ]] || {
  printf 'K3s: Quellenpruefung fehlt; nichts geaendert.\n' >&2
  exit 1
}
exec python3 -I -B "$HELPER" k3s "$@"
