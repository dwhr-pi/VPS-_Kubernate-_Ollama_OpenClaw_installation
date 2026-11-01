#!/usr/bin/env bash
# No mutable vendor script, status adoption, download or service start.
set -Eeuo pipefail
ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
HELPER="$ROOT/scripts/security/core_source_gate.py"
[[ -f "$HELPER" && ! -L "$HELPER" ]] || {
  printf 'Ollama: Quellenpruefung fehlt; nichts geaendert.\n' >&2
  exit 1
}
exec python3 -I -B "$HELPER" ollama "$@"
